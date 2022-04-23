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
    @EnvironmentObject var library: MediaLibrary
    let reloadHandler: () -> Void
    
    var body: some View {
        Section(footer: FooterView(updateInProgress: $config.updateInProgress)) {
            Button("Reload Media", action: self.reloadHandler)
            Button("Update Media", action: self.updateMedia)
                .disabled(self.config.updateInProgress)
            Button("Reset Library", action: self.resetLibrary)
        }
    }
    
    func updateMedia() {
        self.config.updateInProgress = true
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
                    self.config.updateInProgress = false
                    let format = NSLocalizedString("%lld media objects have been updated.", tableName: "Plurals")
                    AlertHandler.showSimpleAlert(
                        title: NSLocalizedString("Update Completed"),
                        message: String.localizedStringWithFormat(format, updateCount)
                    )
                }
            } catch {
                print("Error updating media objects: \(error)")
                // Update UI on the main thread
                await MainActor.run {
                    AlertHandler.showSimpleAlert(
                        title: NSLocalizedString("Update Error"),
                        message: NSLocalizedString("Error updating media objects: \(error.localizedDescription)")
                    )
                    self.config.updateInProgress = false
                }
            }
        }
    }
    
    func resetLibrary() {
        let controller = UIAlertController(
            title: NSLocalizedString("Reset Library"),
            message: NSLocalizedString("This will delete all media objects in your library. Do you want to continue?"),
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel"), style: .cancel))
        controller.addAction(UIAlertAction(
            title: NSLocalizedString("Delete"),
            style: .destructive
        ) { _ in
            // Don't reset the tags, only the media objects
            do {
                try self.library.reset()
            } catch let e {
                print("Error resetting media library")
                print(e)
                AlertHandler.showSimpleAlert(
                    title: NSLocalizedString("Error resetting library"),
                    message: e.localizedDescription
                )
            }
        })
        AlertHandler.presentAlert(alert: controller)
    }
    
    struct FooterView: View {
        @Binding var updateInProgress: Bool
        
        var body: some View {
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    ZStack {
                        // Update Progress
                        AnyView(
                            HStack {
                                ProgressView()
                                Text("Updating media library...")
                            }
                        )
                        .hidden(condition: !updateInProgress)
                    }
                    .frame(height: updateInProgress ? nil : 0)
                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                    Text("Version \(appVersion ?? "unknown")")
                }
                Spacer()
            }
        }
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
