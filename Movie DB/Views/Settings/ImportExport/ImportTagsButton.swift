//
//  ImportTagsButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import SwiftUI

struct ImportTagsButton: View {
    @Binding var config: SettingsViewConfig
    @State private var isImportingTags = false
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    
    var body: some View {
        Button(Strings.Settings.importTagsLabel) { isImportingTags = true }
            .fileImporter(isPresented: $isImportingTags, allowedContentTypes: [.plainText]) { result in
                do {
                    let url = try result.get()
                    self.importTags(url: url)
                } catch {
                    print(error)
                }
            }
    }
    
    func importTags(url: URL) {
        // Initialize the logger
        self.config.importLogger = .init()
        ImportExportSection.import(isLoading: $config.isLoading) { importContext in
            importContext.name = "\(url.lastPathComponent) Tag Import Context"
            
            let importData = try String(contentsOf: url)
            print("Imported Tag Export file. Trying to import into library.")
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
                            // TODO: Duplicate error handling. Would prefer to rethrow the error, but we are in a Task
                            // Use the background context for importing the tags
                            do {
                                try await TagImporter.import(importData, into: importContext)
                                await PersistenceController.saveContext(importContext)
                            } catch {
                                print(error)
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

struct ImportTagsButton_Previews: PreviewProvider {
    static var previews: some View {
        ImportTagsButton(config: .constant(.init()))
    }
}
