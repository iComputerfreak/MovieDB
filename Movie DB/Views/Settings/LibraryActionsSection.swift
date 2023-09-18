//
//  LibraryActionsSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import os.log
import SwiftUI

struct LibraryActionsSection: View {
    @Binding var config: SettingsViewModel
    @EnvironmentObject var preferences: JFConfig
    @State private var library: MediaLibrary = .shared
    let reloadHandler: () -> Void
    
    var body: some View {
        Section(footer: FooterView()) {
            Button(Strings.Settings.updateLibraryLabel, action: self.updateMedia)
            Button(Strings.Settings.reloadLibraryLabel, action: self.reloadHandler)
            Button(Strings.Settings.resetLibraryLabel, action: self.resetLibrary)
            #if DEBUG
                // Don't show the debug button when doing App Store screenshots via Fastlane
                if ProcessInfo.processInfo.environment["FASTLANE_SNAPSHOT"] != "YES" {
                    Button("Debug") {
                        // swiftlint:disable force_try
                        // Do debugging things here
                        var shows = try! PersistenceController.viewContext.fetch(Show.fetchRequest())
                        shows = shows.filter { show in
                            show.seasons.max(on: \.seasonNumber, by: <)?.episodeCount == 0
                        }
                        for show in shows {
                            let seasons = show.seasons.map { "\($0.seasonNumber),\($0.episodeCount)" }.sorted()
                            print("\(show.title) (\(show.numberOfSeasons ?? -1) != \(show.seasons.count)): \(seasons)")
                        }
                        // swiftlint:enable force_try
                    }
                }
            #endif
        }
        .disabled(self.config.isLoading)
    }
    
    struct FooterView: View {
        var body: some View {
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    // Made with love footer
                    Text(Strings.Settings.madeWithLoveFooter)
                        .bold()
                    // App version
                    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text(Strings.Settings.versionFooter(appVersion))
                            .italic()
                    }
                }
                Spacer()
            }
        }
    }
    
    func updateMedia() {
        config.beginLoading(Strings.Settings.ProgressView.updateMedia)
        // Execute the update in the background
        Task(priority: .userInitiated) {
            // We have to handle our errors inside this task manually, otherwise they are simply discarded
            do {
                // Update the available TMDB Languages
                try await Utils.updateTMDBLanguages()
                // Update and show the result
                let updateCount = try await self.library.update()
                
                // Report back the result to the user on the main thread
                await MainActor.run {
                    self.config.stopLoading()
                    AlertHandler.showSimpleAlert(
                        title: Strings.Settings.Alert.updateMediaTitle,
                        message: Strings.Settings.Alert.updateMediaMessage(updateCount)
                    )
                }
            } catch {
                Logger.library.error("Error updating media objects: \(error, privacy: .public)")
                // Update UI on the main thread
                await MainActor.run {
                    AlertHandler.showError(
                        title: Strings.Settings.Alert.libraryUpdateErrorTitle,
                        error: error
                    )
                    self.config.stopLoading()
                }
            }
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
            reloadHandler: {}
        )
    }
}

#Preview("Loading") {
    List {
        LibraryActionsSection(
            config: .constant(SettingsViewModel(isLoading: true, loadingText: "Loading...")),
            reloadHandler: {}
        )
    }
}
