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
    // Reference to the config instance
    @ObservedObject private var preferences = JFConfig.shared
    @State private var library: MediaLibrary = .shared
    
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    
    @State private var config = SettingsViewConfig()
    
    var body: some View {
        LoadingView(
            isShowing: $config.isLoading,
            text: config.loadingText ?? Strings.Settings.loadingPlaceholder
        ) {
            NavigationStack {
                Form {
                    PreferencesSection(config: $config, reloadHandler: self.reloadMedia)
                    if !Utils.purchasedPro() {
                        ProSection(config: $config)
                    }
                    ImportExportSection(config: $config)
                    ContactSection(config: $config)
                    LibraryActionsSection(config: $config, reloadHandler: self.reloadMedia)
                }
                .environmentObject(preferences)
                .navigationTitle(Strings.TabView.settingsLabel)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink(Strings.Settings.navBarButtonLegal) {
                            LegalView()
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink {
                            DebugView()
                        } label: {
                            Text(verbatim: "Debug")
                        }
                    }
                }
                .notificationPopup(
                    isPresented: $config.isShowingReloadCompleteNotification,
                    systemImage: "checkmark",
                    title: "Reload complete",
                    subtitle: nil
                )
            }
        }
    }
    
    func reloadMedia() {
        config.showProgress(Strings.Settings.ProgressView.reloadLibrary)
        
        // Perform the reload in the background on a different thread
        Task(priority: .userInitiated) {
            Logger.library.info("Starting reload...")
            do {
                // Reload and show the result
                try await self.library.reloadAll()
                await MainActor.run {
                    self.config.hideProgress()
                    AlertHandler.showSimpleAlert(
                        title: Strings.Settings.Alert.reloadCompleteTitle,
                        message: Strings.Settings.Alert.reloadCompleteMessage
                    )
                }
            } catch {
                Logger.library.fault("Error reloading media objects: \(error, privacy: .public)")
                await MainActor.run {
                    self.config.hideProgress()
                    AlertHandler.showError(
                        title: Strings.Settings.Alert.reloadErrorTitle,
                        error: error
                    )
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
