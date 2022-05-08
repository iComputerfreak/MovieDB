//
//  ImportExportSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

struct ImportExportSection: View {
    @State private var importLogger: TagImporter.BasicLogger?
    @State private var importLogShowing = false
    @State private var documentPicker: DocumentPicker?
    @Binding var config: SettingsViewConfig
    
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    
    var body: some View {
        Section {
            // MARK: - Import Button
            Button("Import Media", action: self.importMedia)
            
            // MARK: - Export Button
            Button(action: self.exportMedia) {
                Text("Export Media")
            }
            
            // MARK: - Import Tags
            Button("Import Tags", action: self.importTags)
                // MARK: Import Log Popover
                .popover(item: self.$importLogger) { logger in
                    ImportLogViewer(logger: logger)
                }
            
            // MARK: - Export Tags
            Button("Export Tags", action: self.exportTags)
        }
    }
    
    func importMedia() {
        if !Utils.purchasedPro() {
            let mediaCount = MediaLibrary.shared.mediaCount() ?? 0
            guard mediaCount < JFLiterals.nonProMediaLimit else {
                self.config.isShowingProInfo = true
                return
            }
        }
        self.import { importContext, url in
            // Parse the CSV data
            let csvString = try String(contentsOf: url)
            print("Read csv file. Trying to import into library.")
            CSVHelper.importMediaObjects(
                csvString: csvString,
                importContext: importContext,
                onProgress: { progress in
                    // Update the loading view
                    self.config.loadingText = "Loading\n\(progress)\nmedia objects..."
                }, onFail: { log in
                    importLogger?.log(contentsOf: log, level: .info)
                    importLogger?.critical("Importing failed!")
                    self.importLogShowing = true
                }, onFinish: { mediaObjects, log in
                    importLogger?.log(contentsOf: log, level: .info)
                    // Presenting will change UI
                    Task {
                        await MainActor.run {
                            let format = NSLocalizedString(
                                "Imported %lld media objects.",
                                tableName: "Plurals",
                                comment: "Message of an alert asking the user to confirm the import"
                            )
                            let controller = UIAlertController(
                                title: NSLocalizedString(
                                    "Import",
                                    comment: "Title of an alert asking the user to confirm the import"
                                ),
                                message: String.localizedStringWithFormat(format, mediaObjects.count),
                                preferredStyle: .alert
                            )
                            controller.addAction(UIAlertAction(
                                title: NSLocalizedString(
                                    "Undo",
                                    comment: "Button to undo the finished import"
                                ),
                                style: .destructive
                            ) { _ in
                                // Reset all the work we have just done
                                importContext.reset()
                                importLogger?.info("Undoing import. All imported objects removed.")
                                self.importLogShowing = true
                            })
                            controller.addAction(UIAlertAction(
                                title: NSLocalizedString("Ok", comment: "Button to confirm the import"),
                                style: .default
                            ) { _ in
                                Task {
                                    // Make the changes to this context permanent by saving them to disk
                                    await PersistenceController.saveContext(importContext)
                                    await MainActor.run {
                                        // TODO: Why does this not introduce a race condition? (Modifying the _log Variable)
                                        self.importLogger?.info("Import complete.")
                                        self.importLogShowing = true
                                    }
                                }
                            })
                            self.config.isLoading = false
                            // Reset the loading text
                            self.config.loadingText = nil
                            AlertHandler.presentAlert(alert: controller)
                        }
                    }
                }
            )
        }
    }
    
    func exportMedia() {
        export(filename: "MovieDB_Export_\(Utils.isoDateString()).csv") { context in
            let medias = Utils.allMedias(context: context)
            return CSVManager.createCSV(from: medias)
        }
    }
    
    func importTags() {
        self.import { importContext, url in
            let importData = try String(contentsOf: url)
            print("Imported Tag Export file. Trying to import into library.")
            // Count the non-empty tags
            let count = importData.components(separatedBy: "\n").filter({ !$0.isEmpty }).count
            
            // Ask whether the user really wants to import
            Task {
                await MainActor.run {
                    let controller = UIAlertController(
                        title: NSLocalizedString(
                            "Import",
                            comment: "Title of an alert asking the user to confirm importing the tags"
                        ),
                        message: String(
                            localized: "Do you want to import \(count) tags?",
                            table: "Plurals",
                            comment: "Message of an alert asking the user to confirm importing the tags"
                        ),
                        preferredStyle: .alert
                    )
                    controller.addAction(UIAlertAction(
                        title: NSLocalizedString("Yes", comment: "Button confirming the tag import"),
                        style: .default
                    ) { _ in
                        Task {
                            // TODO: Duplicate error handling. Would prefer to rethrow the error, but we are in a Task
                            // Use the background context for importing the tags
                            do {
                                try await TagImporter.import(importData, into: importContext)
                                await PersistenceController.saveContext(importContext)
                            } catch {
                                print(error)
                                AlertHandler.showError(
                                    title: NSLocalizedString(
                                        "Error Importing Tags",
                                        comment: "Title of an alert informing the user of an error during tag import"
                                    ),
                                    error: error
                                )
                            }
                        }
                    })
                    controller.addAction(UIAlertAction(title: NSLocalizedString(
                        "No",
                        comment: "Button of an alert, cancelling the tag import"
                    ), style: .cancel))
                    AlertHandler.presentAlert(alert: controller)
                    self.config.isLoading = false
                }
            }
        }
    }
    
    func exportTags() {
        export(filename: "MovieDB_Tags_Export_\(Utils.isoDateString()).txt") { context in
            try TagImporter.export(context: context)
        }
    }
    
    // Does not save the imported changes!
    func `import`(_ handler: @escaping (NSManagedObjectContext, URL) throws -> Void) {
        // Use iOS file picker
        self.documentPicker = DocumentPicker(onSelect: { url in
            print("Importing \(url.lastPathComponent).")
            self.config.isLoading = true
            // Document picker finished. Invalidate it.
            self.documentPicker = nil
            
            // Perform the import into a separate context on a background thread
            PersistenceController.shared.container.performBackgroundTask { (importContext: NSManagedObjectContext) in
                // Set the merge policy to not override existing data
                importContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
                importContext.name = "\(url.lastPathComponent) Import Context"
                // Initialize the logger
                self.importLogger = .init()
                do {
                    try handler(importContext, url)
                } catch let error {
                    print("Error importing: \(error)")
                    AlertHandler.showError(
                        title: NSLocalizedString(
                            "Import Error",
                            comment: "Title of an error informing the user about an error during import"
                        ),
                        error: error
                    )
                    Task {
                        await MainActor.run {
                            self.config.isLoading = false
                        }
                    }
                }
            }
        }, onCancel: {
            print("Canceling...")
            self.documentPicker = nil
        })
    }
    
    func export(filename: String, content: @escaping (NSManagedObjectContext) throws -> String) {
        print("Exporting \(filename)...")
        self.config.isLoading = true
        
        Task {
            await PersistenceController.shared.container.performBackgroundTask { context in
                context.name = "\(filename) Export Context"
                var url: URL?
                do {
                    // Get the content to export
                    let exportData: String = try content(context)
                    // Save as a file to share it
                    url = Utils.documentsPath.appendingPathComponent(filename)
                    try exportData.write(to: url!, atomically: true, encoding: .utf8)
                    Utils.share(items: [url!])
                } catch {
                    print("Error writing Export file")
                    print(error)
                    // Stop the loading animation
                    Task {
                        await MainActor.run {
                            self.config.isLoading = false
                        }
                    }
                    return
                }
                Task {
                    await MainActor.run {
                        self.config.isLoading = false
                    }
                }
            }
        }
    }
}

struct ImportExportSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ImportExportSection(config: .constant(SettingsViewConfig()))
        }
    }
}
