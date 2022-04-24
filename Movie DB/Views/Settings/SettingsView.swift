//
//  SettingsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import JFSwiftUI
import CoreData
import CSVImporter

struct SettingsView: View {
    // Reference to the config instance
    @ObservedObject private var preferences = JFConfig.shared
    @ObservedObject private var library = MediaLibrary.shared
    
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    
    @State private var config = SettingsViewConfig()
    
    var body: some View {
        LoadingView(isShowing: $config.isLoading, text: config.loadingText ?? NSLocalizedString("Loading...")) {
            NavigationView {
                Form {
                    PreferencesSection(config: $config, reloadHandler: self.reloadMedia)
                    if !Utils.purchasedPro() {
                        ProSection(config: $config)
                    }
                    ImportExportSection(config: $config)
                    LibraryActionsSection(config: $config, reloadHandler: self.reloadMedia)
                }
                .environmentObject(preferences)
                .environmentObject(library)
                .navigationTitle("Settings")
                // TODO: Localize Legal
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink("Legal", destination: LegalView())
                    }
                }
            }
        }
    }
    
    func reloadMedia() {
        self.config.reloadInProgress = true
        
        // Perform the reload in the background on a different thread
        Task {
            print("Starting reload...")
            do {
                // Reload and show the result
                try await self.library.reloadAll()
                await MainActor.run {
                    self.config.reloadInProgress = false
                    AlertHandler.showSimpleAlert(
                        title: NSLocalizedString("Reload Completed"),
                        message: NSLocalizedString("All media objects have been reloaded.")
                    )
                }
            } catch {
                print("Error reloading media objects: \(error)")
                await MainActor.run {
                    self.config.reloadInProgress = false
                    AlertHandler.showError(title: NSLocalizedString("Error reloading library"), error: error)
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

struct SettingsViewConfig {
    var updateInProgress = false
    var reloadInProgress = false
    var isLoading = false
    var loadingText: String?
    var languageChanged = false
    var regionChanged = false
    var isShowingProInfo = false
}
