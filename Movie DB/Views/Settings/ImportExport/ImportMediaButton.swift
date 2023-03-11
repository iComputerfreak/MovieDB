//
//  ImportMediaButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import os.log
import SwiftUI

struct ImportMediaButton: View {
    @Binding var config: SettingsViewConfig
    @State private var isImportingMedia = false
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    
    var body: some View {
        Button(Strings.Settings.importMediaLabel, action: { isImportingMedia = true })
            .fileImporter(isPresented: $isImportingMedia, allowedContentTypes: [.commaSeparatedText]) { result in
                do {
                    let url = try result.get()
                    self.importMedia(url: url)
                } catch {
                    // Error picking file to import. No need to display an error, as the user is probably aware?
                    Logger.importExport.error("Error picking import file: \(error, privacy: .public)")
                }
            }
    }
    
    func importMedia(url: URL) {
        if !Utils.purchasedPro() {
            let mediaCount = MediaLibrary.shared.mediaCount() ?? 0
            guard mediaCount < JFLiterals.nonProMediaLimit else {
                config.isShowingProInfo = true
                return
            }
        }
        // Initialize the logger
        self.config.importLogger = .init()
        ImportExportSection.import(isLoading: $config.isLoading) { importContext in
            importContext.type = .backgroundContext
            
            // Parse the CSV data
            let csvString = try String(contentsOf: url)
            Logger.importExport.debug("Successfully read CSV file. Trying to import into library...")
            CSVHelper.importMediaObjects(
                csvString: csvString,
                importContext: importContext,
                onProgress: { progress in
                    // Update the loading view
                    self.config.loadingText = Strings.Settings.loadingTextMediaImport(progress)
                }, onFail: { log in
                    config.importLogger?.log(contentsOf: log, level: .info)
                    config.importLogger?.critical("Importing failed!")
                    self.config.importLogShowing = true
                }, onFinish: { mediaObjects, log in
                    config.importLogger?.log(contentsOf: log, level: .info)
                    // Presenting will change UI
                    Task(priority: .userInitiated) {
                        await MainActor.run {
                            let controller = UIAlertController(
                                title: Strings.Settings.Alert.importMediaConfirmTitle,
                                message: Strings.Settings.Alert.importMediaConfirmMessage(mediaObjects.count),
                                preferredStyle: .alert
                            )
                            controller.addAction(UIAlertAction(
                                title: Strings.Settings.Alert.importMediaConfirmButtonUndo,
                                style: .destructive
                            ) { _ in
                                // Reset all the work we have just done
                                importContext.reset()
                                config.importLogger?.info("Undoing import. All imported objects removed.")
                                self.config.importLogShowing = true
                            })
                            controller.addAction(.okayAction { _ in
                                Task(priority: .userInitiated) {
                                    // Make the changes to this context permanent by saving them to the
                                    // main context and then to disk
                                    await PersistenceController.saveContext(importContext)
                                    await PersistenceController.saveContext(PersistenceController.viewContext)
                                    await MainActor.run {
                                        self.config.importLogger?.info("Import complete.")
                                        self.config.importLogShowing = true
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
}

struct ImportMediaButton_Previews: PreviewProvider {
    static var previews: some View {
        ImportMediaButton(config: .constant(.init()))
    }
}
