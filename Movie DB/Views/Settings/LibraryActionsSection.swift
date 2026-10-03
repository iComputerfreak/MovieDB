// Copyright © 2022 Jonas Frey. All rights reserved.

import CoreData
import Foundation
import os.log
import SwiftUI
import Analytics

struct LibraryActionsSection: View {
    @Binding var config: SettingsViewModel
    @EnvironmentObject var preferences: JFConfig
    @State private var library: MediaLibrary = .shared
    let updateHandler: () -> Void
    let reloadHandler: () -> Void
    let cancelHandler: () -> Void

    /// Whether the update button should cancel its active operation on iOS 26 or newer.
    private var isUpdateCancellable: Bool {
        guard #available(iOS 26, *) else { return false }
        return config.activeLibraryOperation == .manualUpdate
    }

    /// Whether the reload button should cancel its active operation on iOS 26 or newer.
    private var isReloadCancellable: Bool {
        guard #available(iOS 26, *) else { return false }
        return config.activeLibraryOperation == .manualReload
    }
    
    var body: some View {
        Section {
            Button(action: isUpdateCancellable ? cancelHandler : updateHandler) {
                SettingsActionLabel(
                    title: isUpdateCancellable
                        ? Strings.Settings.cancelLibraryUpdateLabel
                        : Strings.Settings.updateLibraryLabel,
                    systemImage: isUpdateCancellable
                        ? "xmark.circle.fill"
                        : "square.and.arrow.down.on.square.fill",
                    tint: isUpdateCancellable ? .red : .green
                )
            }
            .disabled(config.isLoading && !isUpdateCancellable)
            Button(action: isReloadCancellable ? cancelHandler : reloadHandler) {
                SettingsActionLabel(
                    title: isReloadCancellable
                        ? Strings.Settings.cancelLibraryReloadLabel
                        : Strings.Settings.reloadLibraryLabel,
                    systemImage: isReloadCancellable ? "xmark.circle.fill" : "arrow.clockwise.circle.fill",
                    tint: isReloadCancellable ? .red : .indigo
                )
            }
            .disabled(config.isLoading && !isReloadCancellable)
            Button(action: self.resetLibrary) {
                SettingsActionLabel(
                    title: Strings.Settings.resetLibraryLabel,
                    systemImage: "trash.fill",
                    tint: .red
                )
            }
            .disabled(config.isLoading)
            #if DEBUG
                // Don't show the debug button when doing App Store screenshots via Fastlane
                if ProcessInfo.processInfo.environment["FASTLANE_SNAPSHOT"] != "YES" {
                    Button {
                        // Do debugging things here
                        Task {
                            let duplicateMedia = try await TMDBAPI.shared.media(
                                for: 580,
                                type: .movie,
                                context: PersistenceController.viewContext
                            )
                            PersistenceController.viewContext.insert(duplicateMedia)
                            PersistenceController.saveContext()
                        }
                    } label: {
                        SettingsActionLabel(title: "Debug", systemImage: "ladybug", tint: .indigo)
                    }
                    .disabled(config.isLoading)
                }
            #endif
        } header: {
            Text(Strings.Settings.librarySectionHeader)
        }
    }

    func resetLibrary() {
        let controller = UIAlertController(
            title: Strings.Settings.Alert.resetLibraryConfirmTitle,
            message: Strings.Settings.Alert.resetLibraryConfirmMessage,
            preferredStyle: .alert
        )
        controller.addAction(.cancelAction())
        controller.addAction(UIAlertAction(
            title: Strings.Settings.Alert.resetLibraryConfirmButtonDelete,
            style: .destructive
        ) { _ in
            config.beginLoading(Strings.Settings.ProgressView.resetLibrary)
            Task(priority: .userInitiated) {
                do {
                    Logger.library.info("Resetting Library...")
                    AnalyticsService.shared.track(.libraryReset)
                    try self.library.reset()
                } catch {
                    Logger.library.error("Error resetting library: \(error, privacy: .public)")
                    AlertHandler.showError(
                        title: Strings.Settings.Alert.resetLibraryErrorTitle,
                        error: error
                    )
                }
                await MainActor.run {
                    self.config.stopLoading()
                }
            }
        })
        AlertHandler.presentAlert(alert: controller)
    }
}

#Preview {
    List {
        LibraryActionsSection(
            config: .constant(SettingsViewModel()),
            updateHandler: {},
            reloadHandler: {},
            cancelHandler: {}
        )
    }
}

#Preview("Loading") {
    List {
        LibraryActionsSection(
            config: .constant(SettingsViewModel(isLoading: true, loadingText: "Loading...")),
            updateHandler: {},
            reloadHandler: {},
            cancelHandler: {}
        )
    }
}
