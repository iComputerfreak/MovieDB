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
    @State private var library: MediaLibrary = .shared
    
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    
    @State private var config = SettingsViewConfig()
    
    var body: some View {
        // TODO: Should settings really use a loading screen?
        LoadingView(
            isShowing: $config.isLoading,
            text: config.loadingText ?? String(
                localized: "settings.placeholder.loading",
                comment: "Placeholder text to show while the data is loading"
            )
        ) {
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
                .navigationTitle(String(
                    localized: "tabView.settings.label",
                    comment: "The label of the settings tab of the main TabView"
                ))
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink(
                            String(
                                localized: "settings.navBar.button.legal",
                                // swiftlint:disable:next line_length
                                comment: "The 'Legal' button that leads to the legal view in the settings' navigation bar"
                            ),
                            destination: LegalView()
                        )
                    }
                }
            }
        }
    }
    
    func reloadMedia() {
        self.config.showProgress("Reloading media objects...")
        
        // Perform the reload in the background on a different thread
        Task {
            print("Starting reload...")
            do {
                // Reload and show the result
                try await self.library.reloadAll()
                await MainActor.run {
                    self.config.hideProgress()
                    AlertHandler.showSimpleAlert(
                        title: String(
                            localized: "settings.alert.reloadCompleted.title",
                            comment: "Title of the alert informing the user that the media reload is completed"
                        ),
                        message: String(
                            localized: "settings.alert.reloadCompleted.message",
                            comment: "Message of the alert informing the user that the media reload is completed"
                        )
                    )
                }
            } catch {
                print("Error reloading media objects: \(error)")
                await MainActor.run {
                    self.config.hideProgress()
                    AlertHandler.showError(
                        title: String(
                            localized: "settings.alert.errorReloadingLibrary.title",
                            comment: "Title of an alert informing the user about an error while reloading the library"
                        ),
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

struct SettingsViewConfig {
    var showingProgress = false
    private(set) var progressText: String = ""
    var isLoading = false
    var loadingText: String?
    var languageChanged = false
    var regionChanged = false
    var isShowingProInfo = false
    
    mutating func showProgress(_ text: String) {
        self.showingProgress = true
        self.progressText = text
    }
    
    mutating func hideProgress() {
        self.showingProgress = false
        self.progressText = ""
    }
}
