// Copyright © 2019 Jonas Frey. All rights reserved.

import CoreData
import Analytics
import JFSwiftUI
import os.log
import SwiftUI

struct SettingsView: View {
    @State private var library: MediaLibrary = .shared
    
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    @EnvironmentObject private var config: JFConfig

    private let storeManager: StoreManager = .shared

    @State private var viewModel = SettingsViewModel()
    @State private var libraryOperationTask: Task<Void, Never>?
    @State private var isShowingAnalyticsConsent = false
    @State private var pendingAnalyticsEnableSource: AnalyticsEnabledSource?
    @State private var error: (any Error)?
    @State private var isShowingReloadCompleteAlert = false
    @State private var updateCompleteMessage: String?

    @ToolbarContentBuilder
    private var debugMenuToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            NavigationLink {
                DebugView()
            } label: {
                Label {
                    Text(verbatim: "Debug")
                } icon: {
                    Image(systemName: "ladybug")
                }
            }
            .tint(.accentColor)
        }
    }
    
    var body: some View {
        LoadingView(
            isShowing: Binding(
                get: { viewModel.isLoading && viewModel.showsBlockingLoadingIndicator },
                set: { viewModel.isLoading = $0 }
            ),
            text: viewModel.loadingText ?? Strings.Settings.loadingPlaceholder
        ) {
            NavigationStack {
                Form {
                    PreferencesSection(
                        config: $viewModel,
                        reloadHandler: self.reloadMedia
                    )
                    if !storeManager.hasPurchasedPro {
                        ProSection(config: $viewModel)
                    }
                    ImportExportSection(config: $viewModel)
                    ContactSection(config: $viewModel)
                    LibraryActionsSection(
                        config: $viewModel,
                        updateHandler: self.updateMedia,
                        reloadHandler: self.reloadMedia,
                        cancelHandler: self.cancelLibraryOperation
                    )
                    AnalyticsSection(
                        enableAnalyticsHandler: { isShowingAnalyticsConsent = true },
                        disableAnalyticsHandler: disableAnalytics
                    )
                }
                .environmentObject(config)
                .navigationTitle(Strings.TabView.settingsLabel)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink(Strings.Settings.navBarButtonLegal) {
                            LegalView()
                        }
                    }
                    if
                        AnalyticsService.shared.isFeatureEnabled(.debugging),
                        // When we do App Store screenshots, we hide the debug menu
                        !CommandLine.launchArguments.contains(.screenshots)
                    {
                        debugMenuToolbarItem
                    }
                }
                .notificationPopup(
                    isPresented: $viewModel.isShowingReloadCompleteNotification,
                    systemImage: "checkmark",
                    title: Strings.Detail.reloadCompleteNotificationTitle,
                    subtitle: nil
                )
            }
        }
        .onAppear {
            AnalyticsService.shared.track(.screenViewed(screenName: .settings))
        }
        .sheet(isPresented: $isShowingAnalyticsConsent, onDismiss: finalizeAnalyticsOptIn) {
            AnalyticsConsentView(
                onAllow: {
                    pendingAnalyticsEnableSource = .settings
                    config.analyticsConsentState = .allowed
                    isShowingAnalyticsConsent = false
                },
                onKeepOff: {
                    config.analyticsConsentState = .denied
                    isShowingAnalyticsConsent = false
                }
            )
            .presentationDetents([.large])
        }
        .messageAlert(
            title: Strings.Settings.Alert.reloadCompleteTitle,
            message: Strings.Settings.Alert.reloadCompleteMessage,
            isPresented: $isShowingReloadCompleteAlert
        )
        .messageAlert(title: Strings.Settings.Alert.updateMediaTitle, message: $updateCompleteMessage)
        .errorAlert(error: $error)
    }

    /// Starts a full manual library reload.
    @MainActor
    func reloadMedia() {
        guard !viewModel.isLoading else { return }

        AnalyticsService.shared.track(.libraryReload)
        let showsBlockingIndicator = if #available(iOS 26, *) { false } else { true }
        viewModel.beginLoading(
            Strings.Settings.ProgressView.reloadLibrary,
            showsBlockingIndicator: showsBlockingIndicator
        )
        viewModel.activeLibraryOperation = .manualReload

        libraryOperationTask = Task(priority: .userInitiated) { @MainActor in
            Logger.library.info("Starting reload...")
            do {
                try await self.library.reloadAll(origin: .manualReload)
                try Task.checkCancellation()
                isShowingReloadCompleteAlert = true
            } catch {
                if Task.isCancelled || error is CancellationError {
                    Logger.library.info("Library reload cancelled.")
                } else {
                    Logger.library.fault("Error reloading media objects: \(error, privacy: .public)")
                    self.error = error
                }
            }
            self.viewModel.stopLoading()
            self.libraryOperationTask = nil
        }
    }

    /// Starts a manual update of changed library items.
    @MainActor
    private func updateMedia() {
        guard !viewModel.isLoading else { return }

        let showsBlockingIndicator = if #available(iOS 26, *) { false } else { true }
        viewModel.beginLoading(
            Strings.Settings.ProgressView.updateMedia,
            showsBlockingIndicator: showsBlockingIndicator
        )
        viewModel.activeLibraryOperation = .manualUpdate

        libraryOperationTask = Task(priority: .userInitiated) { @MainActor in
            do {
                try await Utils.updateTMDBLanguages()
                let updateCount = try await self.library.update()
                try Task.checkCancellation()
                updateCompleteMessage = Strings.Settings.Alert.updateMediaMessage(updateCount)
                AnalyticsService.shared.track(.libraryUpdate(result: .success))
            } catch {
                if Task.isCancelled || error is CancellationError {
                    Logger.library.info("Library update cancelled.")
                } else {
                    Logger.library.error("Error updating media objects: \(error, privacy: .public)")
                    AnalyticsService.shared.track(.libraryUpdate(result: .failure))
                    self.error = error
                }
            }
            self.viewModel.stopLoading()
            self.libraryOperationTask = nil
        }
    }

    /// Cancels the manual library operation started from Settings.
    private func cancelLibraryOperation() {
        libraryOperationTask?.cancel()
    }

    private func disableAnalytics() {
        config.analyticsConsentState = .denied
        AnalyticsService.shared.setTrackingEnabled(false)
    }

    private func finalizeAnalyticsOptIn() {
        guard let source = pendingAnalyticsEnableSource else { return }

        AnalyticsService.shared.setTrackingEnabled(true)
        AnalyticsService.shared.reloadFeatureFlags {
            Task {
                _ = BackgroundHandler().refreshBackgroundFetch()
            }
        }
        AnalyticsService.shared.track(.analyticsEnabled(source: source))
        pendingAnalyticsEnableSource = nil
    }
}

#Preview {
    SettingsView()
        .previewEnvironment()
}
