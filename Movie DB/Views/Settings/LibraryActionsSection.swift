//
//  LibraryActionsSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct LibraryActionsSection: View {
    @Binding var config: SettingsViewConfig
    @EnvironmentObject var preferences: JFConfig
    @State private var library: MediaLibrary = .shared
    let reloadHandler: () -> Void
    
    var body: some View {
        Section(footer: FooterView(showingProgress: $config.showingProgress, progressText: config.progressText)) {
            Button("Reload Media", action: self.reloadHandler)
            Button("Update Media", action: self.updateMedia)
            Button("Reset Library", action: self.resetLibrary)
            Button("Reset Tags", action: self.resetTags)
        }
        .disabled(self.config.showingProgress)
    }
    
    // swiftlint:disable:next type_contents_order
    struct FooterView: View {
        @Binding var showingProgress: Bool
        let progressText: LocalizedStringKey
        
        var body: some View {
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    ZStack {
                        // Update Progress
                        AnyView(
                            HStack(spacing: 5) {
                                ProgressView()
                                Text(progressText)
                            }
                        )
                        .hidden(condition: !showingProgress)
                    }
                    .frame(height: showingProgress ? nil : 0)
                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                    Text(
                        "settings.footer.version \(appVersion ?? "unknown")",
                        comment: "The version information at the bottom of the settings page"
                    )
                }
                Spacer()
            }
        }
    }
    
    func updateMedia() {
        self.config.showProgress("Updating media objects...")
        // Execute the update in the background
        Task {
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
                        title: String(
                            localized: "settings.alert.updateMediaComplete.title",
                            comment: "Title of an alert informing the user that the library update is completed"
                        ),
                        message: String(
                            localized: "settings.alert.updateMediaComplete.message \(updateCount)",
                            // swiftlint:disable:next line_length
                            comment: "Message of an alert informing the user how many media objects have been updated. The argument is the count of updated objects"
                        )
                    )
                }
            } catch {
                print("Error updating media objects: \(error)")
                // Update UI on the main thread
                await MainActor.run {
                    AlertHandler.showError(
                        title: String(
                            localized: "settings.alert.libraryUpdateError.title",
                            comment: "Title of an alert informing the user of an error while updating the library"
                        ),
                        error: error
                    )
                    self.config.hideProgress()
                }
            }
        }
    }
    
    func resetLibrary() {
        let controller = UIAlertController(
            title: String(
                localized: "settings.alert.resetLibrary.title",
                comment: "Title of an alert asking the user for confirmation to reset the library"
            ),
            message: String(
                localized: "settings.alert.resetLibrary.message",
                comment: "Message of an alert asking the user for confirmation to reset the library"
            ),
            preferredStyle: .alert
        )
        controller.addAction(.cancelAction())
        controller.addAction(UIAlertAction(
            title: String(
                localized: "settings.alert.resetLibrary.button.delete",
                comment: "Button to confirm the library reset"
            ),
            style: .destructive
        ) { _ in
            Task(priority: .userInitiated) {
                await MainActor.run {
                    self.config.showProgress("Resetting Library...")
                }
                do {
                    try await self.library.reset()
                } catch {
                    print("Error resetting library")
                    print(error)
                    AlertHandler.showError(
                        title: String(
                            localized: "settings.alert.resetLibraryError.title",
                            comment: "Title of an alert informing the user of an error while resetting the library"
                        ),
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
    
    func resetTags() {
        let controller = UIAlertController(
            title: String(
                localized: "settings.alert.resetTags.title",
                comment: "Title of an alert asking the user to confirm resettings the tags"
            ),
            message: String(
                localized: "settings.alert.resetTags.message",
                comment: "Message of an alert asking the user to confirm resetting the tags"
            ),
            preferredStyle: .alert
        )
        controller.addAction(.cancelAction())
        controller.addAction(UIAlertAction(
            title: String(
                localized: "settings.alert.resetTags.button.delete",
                comment: "Button of an alert, confirming the tag reset"
            ),
            style: .destructive
        ) { _ in
            Task(priority: .userInitiated) {
                await MainActor.run {
                    self.config.showProgress("Resetting Tags...")
                }
                do {
                    try await self.library.resetTags()
                } catch {
                    print("Error resetting tags")
                    print(error)
                    AlertHandler.showError(
                        title: String(
                            localized: "settings.alert.resetTagsError.title",
                            comment: "Title of an alert informing the user of an error during tag reset"
                        ),
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
        List {
            LibraryActionsSection(
                config: .constant(SettingsViewConfig()),
                reloadHandler: {}
            )
        }
    }
}
