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
                #if !targetEnvironment(macCatalyst)
                // swiftlint:disable:next anonymous_argument_in_multiline_closure
                .popover(item: self.$documentPicker, content: { $0 })
                #endif
            
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
                    self.config.loadingText = "Loading \(progress) media objects..."
                }, onFail: { log in
                    importLogger?.log(contentsOf: log, level: .info)
                    importLogger?.critical("Importing failed!")
                    self.importLogShowing = true
                }, onFinish: { mediaObjects, log in
                    importLogger?.log(contentsOf: log, level: .info)
                    // Presenting will change UI
                    Task {
                        await MainActor.run {
                            // TODO: Tell the user how many duplicates were not added
                            let format = NSLocalizedString("Imported %lld media objects.", tableName: "Plurals")
                            let controller = UIAlertController(
                                title: NSLocalizedString("Import"),
                                message: String.localizedStringWithFormat(format, mediaObjects.count),
                                preferredStyle: .alert
                            )
                            controller.addAction(UIAlertAction(
                                title: NSLocalizedString("Undo"),
                                style: .destructive
                            ) { _ in
                                // Reset all the work we have just done
                                importContext.reset()
                                importLogger?.info("Undoing import. All imported objects removed.")
                                self.importLogShowing = true
                            })
                            controller.addAction(UIAlertAction(
                                title: NSLocalizedString("Ok"),
                                style: .default
                            ) { _ in
                                Task {
                                    // Make the changes to this context permanent by saving them to disk
                                    await PersistenceController.saveContext(importContext)
                                    await MainActor.run {
                                        // TODO: Replace when using real logger
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
                    let format = NSLocalizedString("Do you want to import %lld tags?", tableName: "Plurals")
                    let controller = UIAlertController(
                        title: NSLocalizedString("Import"),
                        message: String.localizedStringWithFormat(format, count),
                        preferredStyle: .alert
                    )
                    controller.addAction(UIAlertAction(
                        title: NSLocalizedString("Yes"),
                        style: .default
                    ) { _ in
                        Task {
                            // TODO: Duplicate error handling. Would prefer to rethrow the error, but we are in a Task
                            // Use the background context for importing the tags
                            do {
                                try TagImporter.import(importData, into: importContext)
                                Task {
                                    await PersistenceController.saveContext(importContext)
                                }
                            } catch {
                                print(error)
                                AlertHandler.showSimpleAlert(
                                    title: NSLocalizedString("Error Importing Tags"),
                                    message: error.localizedDescription
                                )
                            }
                        }
                    })
                    controller.addAction(UIAlertAction(title: NSLocalizedString("No"), style: .cancel))
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
        // TODO: Replace DocumentPicker with some async version
        // Use iOS file picker
        self.documentPicker = DocumentPicker(onSelect: { url in
            print("Importing \(url.lastPathComponent).")
            self.config.isLoading = true
            // Document picker finished. Invalidate it.
            self.documentPicker = nil
            
            // Perform the import into a separate context on a background thread
            PersistenceController.shared.container.performBackgroundTask { (importContext: NSManagedObjectContext) in
                // Set the merge policy to not override existing data
                // TODO: Maybe we should?
                importContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
                importContext.name = "\(url.lastPathComponent) Import Context"
                // Initialize the logger
                self.importLogger = .init()
                do {
                    try handler(importContext, url)
                } catch let error as LocalizedError {
                    print("Error importing: \(error)")
                    AlertHandler.showSimpleAlert(
                        title: NSLocalizedString("Import Error"),
                        message: NSLocalizedString("Error Importing: \(error.localizedDescription)")
                    )
                    Task {
                        await MainActor.run {
                            self.config.isLoading = false
                        }
                    }
                } catch let otherError {
                    print("Unknown Error: \(otherError)")
                    assertionFailure("This error should be captured specifically to give the user a more precise " +
                                     "error message.")
                    AlertHandler.showSimpleAlert(
                        title: NSLocalizedString("Import Error"),
                        message: NSLocalizedString("There was an unknown error during import.")
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
        #if targetEnvironment(macCatalyst)
        // On macOS present the file picker manually
        UIApplication.shared.windows[0].rootViewController!.present(self.documentPicker!.viewController, animated: true)
        #endif
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
                #if targetEnvironment(macCatalyst)
                // Show save file dialog
                self.documentPicker = DocumentPicker(urlToExport: url) { url in
                    print("Exporting \(url.lastPathComponent).")
                    // Document picker finished. Invalidate it.
                    Task {
                        await MainActor.run {
                            self.documentPicker = nil
                        }
                    }
                    do {
                        // Export the csv to the file
                        try exportData.write(to: url, atomically: true, encoding: .utf8)
                    } catch {
                        print("Error exporting Export file:")
                        print(error)
                    }
                } onCancel: {
                    print("Canceling...")
                    Task {
                        await MainActor.run {
                            self.documentPicker = nil
                        }
                    }
                }
                // On macOS present the file picker manually
                UIApplication.shared.windows[0].rootViewController!
                    .present(self.documentPicker!.viewController, animated: true)
                #else
                Utils.share(items: [url!])
                #endif
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
