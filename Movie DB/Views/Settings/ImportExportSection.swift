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
                .popover(item: self.$documentPicker) { picker in
                    picker
                }
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
    
    // TODO: Refactor
    func importMedia() {
        if !Utils.purchasedPro() {
            if let mediaCount = MediaLibrary.shared.mediaCount() {
                if mediaCount >= JFLiterals.nonProMediaLimit {
                    self.config.isShowingProInfo = true
                    return
                }
            } else {
                print("Error retrieving media count")
                // continue with import
            }
        }
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
                importContext.name = "Import Context"
                // Initialize the logger
                self.importLogger = .init()
                // Load the CSV data
                do {
                    let csvString = try String(contentsOf: url)
                    print("Read csv file. Trying to import into library.")
                    CSVHelper.importMediaObjects(
                        csvString: csvString,
                        importContext: importContext,
                        onProgress: { progress in
                            // Update the loading view
                            self.config.loadingText = "Loading \(progress) media objects..."
                        },
                        onFail: { log in
                            importLogger?.log(contentsOf: log, level: .info)
                            importLogger?.critical("Importing failed!")
                            self.importLogShowing = true
                        },
                        onFinish: { mediaObjects, log in
                            importLogger?.log(contentsOf: log, level: .info)
                            // Presenting will change UI
                            DispatchQueue.main.async {
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
                    )
                } catch {
                    print("Error importing: \(error)")
                    AlertHandler.showSimpleAlert(
                        title: NSLocalizedString("Import Error"),
                        message: NSLocalizedString("Error importing the media objects: \(error.localizedDescription)")
                    )
                    DispatchQueue.main.async {
                        self.config.isLoading = false
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
    
    func exportMedia() {
        // Prepare for export
        print("Exporting...")
        self.config.isLoading = true
        
        // Perform the export in a separate context on a background thread
        PersistenceController.shared.container.performBackgroundTask { (exportContext: NSManagedObjectContext) in
            exportContext.name = "Export Context"
            let url: URL?
            do {
                let medias = Utils.allMedias(context: self.managedObjectContext)
                let csv = CSVManager.createCSV(from: medias)
                // Save the csv as a file to share it
                url = Utils.documentsPath.appendingPathComponent("MovieDB_Export_\(Utils.isoDateString()).csv")
                try csv.write(to: url!, atomically: true, encoding: .utf8)
            } catch let exception {
                print("Error writing CSV file")
                print(exception)
                self.config.isLoading = false
                return
            }
            #if targetEnvironment(macCatalyst)
            // Show save file dialog
            self.documentPicker = DocumentPicker(urlToExport: url) { url in
                print("Exporting \(url.lastPathComponent).")
                // Document picker finished. Invalidate it.
                self.documentPicker = nil
                do {
                    // Export the csv to the file
                    try csv.write(to: url, atomically: true, encoding: .utf8)
                } catch let exception {
                    print("Error exporting csv file:")
                    print(exception)
                }
            } onCancel: {
                print("Canceling...")
                self.documentPicker = nil
            }
            // On macOS present the file picker manually
            UIApplication.shared.windows[0].rootViewController!
                .present(self.documentPicker!.viewController, animated: true)
            #else
            Utils.share(items: [url!])
            #endif
            self.config.isLoading = false
        }
    }
    
    // TODO: Refactor, use async
    func importTags() {
        // Use iOS file picker
        self.documentPicker = DocumentPicker(onSelect: { url in
            print("Importing \(url.lastPathComponent).")
            self.config.isLoading = true
            // Document picker finished. Invalidate it.
            self.documentPicker = nil
            // TODO: Replace with actor to import the tags
            // TODO: Same for media
            
            DispatchQueue.global().async {
                // Load the CSV data and decode it
                do {
                    let importData = try String(contentsOf: url)
                    print("Imported Tag Export file. Trying to import into library.")
                    // Count the non-empty tags
                    let count = importData.components(separatedBy: "\n").filter({ !$0.isEmpty }).count
                    // Presenting will change UI
                    DispatchQueue.main.async {
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
                            // Use a background context for importing the tags
                            PersistenceController.shared.container.performBackgroundTask { context in
                                context.name = "Tag Import Context"
                                do {
                                    try TagImporter.import(importData, into: context)
                                    Task {
                                        await PersistenceController.saveContext(context)
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
                } catch let error as LocalizedError {
                    print("Error importing: \(error)")
                    AlertHandler.showSimpleAlert(
                        title: NSLocalizedString("Import Error"),
                        message: NSLocalizedString("Error Importing the Tags: \(error.localizedDescription)")
                    )
                    DispatchQueue.main.async {
                        self.config.isLoading = false
                    }
                } catch let otherError {
                    print("Unknown Error: \(otherError)")
                    assertionFailure("This error should be captured specifically to give the user a more precise " +
                                     "error message.")
                    AlertHandler.showSimpleAlert(
                        title: NSLocalizedString("Import Error"),
                        message: NSLocalizedString("There was an error importing the tags.")
                    )
                    DispatchQueue.main.async {
                        self.config.isLoading = false
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
    
    func exportTags() {
        print("Exporting Tags...")
        self.config.isLoading = true
        
        PersistenceController.shared.container.performBackgroundTask { context in
            context.name = "Tag Export Context"
            var url: URL?
            do {
                let exportData: String = try TagImporter.export(context: context)
                // Save as a file to share it
                url = Utils.documentsPath.appendingPathComponent("MovieDB_Tags_Export_\(Utils.isoDateString()).txt")
                try exportData.write(to: url!, atomically: true, encoding: .utf8)
            } catch let exception {
                print("Error writing Tags Export file")
                print(exception)
                self.config.isLoading = false
                return
            }
            #if targetEnvironment(macCatalyst)
            // Show save file dialog
            self.documentPicker = DocumentPicker(urlToExport: url) { url in
                print("Exporting \(url.lastPathComponent).")
                // Document picker finished. Invalidate it.
                self.documentPicker = nil
                do {
                    // Export the csv to the file
                    try exportData.write(to: url, atomically: true, encoding: .utf8)
                } catch let exception {
                    print("Error exporting Tag Export file:")
                    print(exception)
                }
            } onCancel: {
                print("Canceling...")
                self.documentPicker = nil
            }
            // On macOS present the file picker manually
            UIApplication.shared.windows[0].rootViewController!
                .present(self.documentPicker!.viewController, animated: true)
            #else
            Utils.share(items: [url!])
            #endif
            self.config.isLoading = false
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
