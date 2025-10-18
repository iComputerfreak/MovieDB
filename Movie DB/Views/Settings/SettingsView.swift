//
//  SettingsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import CoreData
import JFSwiftUI
import os.log
import SwiftUI

struct SettingsView: View {
    @State private var library: MediaLibrary = .shared
    
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    @EnvironmentObject private var config: JFConfig

    private let storeManager: StoreManager = .shared

    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        LoadingView(
            isShowing: $viewModel.isLoading,
            text: viewModel.loadingText ?? Strings.Settings.loadingPlaceholder
        ) {
            NavigationStack {
                Form {
                    PreferencesSection(config: $viewModel, reloadHandler: self.reloadMedia)
                    if !storeManager.hasPurchasedPro {
                        ProSection(config: $viewModel)
                    }
                    ImportExportSection(config: $viewModel)
                    ContactSection(config: $viewModel)
                    LibraryActionsSection(config: $viewModel, reloadHandler: self.reloadMedia)
                }
                .environmentObject(config)
                .navigationTitle(Strings.TabView.settingsLabel)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink(Strings.Settings.navBarButtonLegal) {
                            LegalView()
                        }
                    }
                    #if DEBUG
                    debugMenuToolbarItem
                    #endif
                }
                .notificationPopup(
                    isPresented: $viewModel.isShowingReloadCompleteNotification,
                    systemImage: "checkmark",
                    title: "Reload complete",
                    subtitle: nil
                )
            }
        }
    }

    @ToolbarContentBuilder
    private var debugMenuToolbarItem: some ToolbarContent {
        // Don't show on screenshots
        if ProcessInfo.processInfo.environment["FASTLANE_SNAPSHOT"] != "YES" {
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
                .tint(.accent)
            }
        }
    }

    func reloadMedia() {
        viewModel.beginLoading(Strings.Settings.ProgressView.reloadLibrary)
        
        // Perform the reload in the background on a different thread
        Task(priority: .userInitiated) {
            Logger.library.info("Starting reload...")
            do {
                // Reload and show the result
                try await self.library.reloadAll()
                await MainActor.run {
                    self.viewModel.stopLoading()
                    AlertHandler.showSimpleAlert(
                        title: Strings.Settings.Alert.reloadCompleteTitle,
                        message: Strings.Settings.Alert.reloadCompleteMessage
                    )
                }
            } catch {
                Logger.library.fault("Error reloading media objects: \(error, privacy: .public)")
                await MainActor.run {
                    self.viewModel.stopLoading()
                    AlertHandler.showError(
                        title: Strings.Settings.Alert.reloadErrorTitle,
                        error: error
                    )
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
