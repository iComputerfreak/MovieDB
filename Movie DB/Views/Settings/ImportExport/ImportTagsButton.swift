//
//  ImportTagsButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import os.log
import SwiftUI

struct ImportTagsButton: View {
    @Binding var config: SettingsViewModel
    @State private var isImportingTags = false
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    
    var body: some View {
        Button(Strings.Settings.importTagsLabel) { isImportingTags = true }
            .fileImporter(isPresented: $isImportingTags, allowedContentTypes: [.plainText]) { result in
                do {
                    let url = try result.get()
                    self.importTags(url: url)
                } catch {
                    Logger.importExport.error("Error importing tags: \(error, privacy: .public)")
                }
            }
    }
    
    func importTags(url: URL) {
        // Initialize the logger
        self.config.importLogger = .init()
        ImportExportSection.import(isLoading: $config.isLoading) { importContext in
            importContext.type = .backgroundContext
            
            guard url.startAccessingSecurityScopedResource() else {
                throw ImportError.noPermissions
            }
            let importData = try String(contentsOf: url)
            url.stopAccessingSecurityScopedResource()
            Logger.importExport.debug("Successfully read tags file. Trying to import into library.")
            // Count the non-empty tags
            let count = importData.components(separatedBy: "\n").filter { !$0.isEmpty }.count
            
            // Ask whether the user really wants to import
            Task(priority: .userInitiated) {
                await MainActor.run {
                    let controller = UIAlertController(
                        title: Strings.Settings.Alert.importTagsConfirmTitle,
                        message: Strings.Settings.Alert.importTagsConfirmMessage(count),
                        preferredStyle: .alert
                    )
                    controller.addAction(.yesAction { _ in
                        Task(priority: .userInitiated) {
                            // Use the background context for importing the tags
                            do {
                                try await TagImporter.import(importData, into: importContext)
                                await PersistenceController.saveContext(importContext)
                            } catch {
                                Logger.importExport.error("Error importing tags: \(error, privacy: .public)")
                                AlertHandler.showError(
                                    title: Strings.Settings.Alert.importTagsErrorTitle,
                                    error: error
                                )
                            }
                        }
                    })
                    controller.addAction(.noAction())
                    AlertHandler.presentAlert(alert: controller)
                    self.config.isLoading = false
                }
            }
        }
    }
}

#Preview {
    ImportTagsButton(config: .constant(.init()))
}
