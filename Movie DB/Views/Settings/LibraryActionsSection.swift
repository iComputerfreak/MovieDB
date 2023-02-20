//
//  LibraryActionsSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import SwiftUI

struct LibraryActionsSection: View {
    @Binding var config: SettingsViewConfig
    @EnvironmentObject var preferences: JFConfig
    @State private var library: MediaLibrary = .shared
    let reloadHandler: () -> Void
    
    var body: some View {
        Section(footer: FooterView(
            showingProgress: $config.showingProgress,
            progressText: config.progressText
        )) {
            Button(Strings.Settings.updateLibraryLabel, action: self.updateMedia)
            Button(Strings.Settings.reloadLibraryLabel, action: self.reloadHandler)
            Button(Strings.Settings.resetLibraryLabel, action: self.resetLibrary)
            #if DEBUG
                // Don't show the debug button when doing App Store screenshots via Fastlane
                if ProcessInfo.processInfo.environment["FASTLANE_SNAPSHOT"] != "YES" {
                    Button("Debug") {
                        // Do debugging things here
                    }
                }
            #endif
        }
        .disabled(self.config.showingProgress)
    }
    
    // swiftlint:disable:next type_contents_order
    struct FooterView: View {
        @Binding var showingProgress: Bool
        let progressText: String
        
        var body: some View {
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    // Update Progress
                    HStack(spacing: 5) {
                        ProgressView()
                        Text(progressText)
                    }
                    .hidden(condition: !showingProgress)
                    .padding(.bottom, showingProgress ? 4 : 0)
                    .frame(height: showingProgress ? nil : 0)
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
        config.showProgress(Strings.Settings.ProgressView.updateMedia)
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
                    self.config.hideProgress()
                    AlertHandler.showSimpleAlert(
                        title: Strings.Settings.Alert.updateMediaTitle,
                        message: Strings.Settings.Alert.updateMediaMessage(updateCount)
                    )
                }
            } catch {
                print("Error updating media objects: \(error)")
                // Update UI on the main thread
                await MainActor.run {
                    AlertHandler.showError(
                        title: Strings.Settings.Alert.libraryUpdateErrorTitle,
                        error: error
                    )
                    self.config.hideProgress()
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
            config.showProgress(Strings.Settings.ProgressView.resetLibrary)
            Task(priority: .userInitiated) {
                do {
                    print("Resetting Library...")
                    try self.library.reset()
                    JFConfig.shared.libraryWasReset = true
                } catch {
                    print("Error resetting library")
                    print(error)
                    AlertHandler.showError(
                        title: Strings.Settings.Alert.resetLibraryErrorTitle,
                        error: error
                    )
                }
                await MainActor.run {
                    self.config.hideProgress()
                }
            }
        })
        AlertHandler.presentAlert(alert: controller)
    }
}

struct LibraryActionsSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            List {
                LibraryActionsSection(
                    config: .constant(SettingsViewConfig()),
                    reloadHandler: {}
                )
            }
        }
        Group {
            VStack {
                LibraryActionsSection.FooterView(showingProgress: .constant(true), progressText: "Loading...")
                    .background(.cyan)
                LibraryActionsSection.FooterView(showingProgress: .constant(false), progressText: "Loading...")
                    .background(.cyan)
            }
        }
        .previewDisplayName("Footer Loading View")
    }
}
