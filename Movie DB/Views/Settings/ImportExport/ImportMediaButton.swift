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
    @Binding var config: SettingsViewModel
    @State private var isImportingMedia = false
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    @EnvironmentObject private var storeManager: StoreManager
    
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
    
    // swiftlint:disable:next function_body_length
    func importMedia(url: URL) {
        if !storeManager.hasPurchasedPro {
            let mediaCount = MediaLibrary.shared.mediaCount() ?? 0
            guard mediaCount < JFLiterals.nonProMediaLimit else {
                config.isShowingProInfo = true
                return
            }
        }
        // Initialize the logger
        self.config.importLogger = .init()
        ImportExportSection.import(isLoading: $config.isLoading) { importContext in
            // Import using CSVImporter
            guard url.startAccessingSecurityScopedResource() else {
                throw ImportError.noPermissions
            }
            let importer = try CSVImporter(url: url)
            url.stopAccessingSecurityScopedResource()
            Logger.importExport.debug("Successfully read CSV file. Trying to import into library...")
            
            let medias: [Media]! // swiftlint:disable:this implicitly_unwrapped_optional
            do {
                medias = try await importer.decodeMediaObjects(importContext: importContext) { progress in
                    self.config.loadingText = Strings.Settings.loadingTextMediaImport(progress, importer.rowCount)
                } log: { message in
                    // TODO: Replace with other logger when reworking import view
                    // TODO: Maybe we can stream a specific OSLog logger to a buffer and display it?
                    self.config.importLogger?.log(message, level: .none)
                }
            } catch {
                DispatchQueue.main.async {
                    self.config.importLogShowing = true
                }
                // Rethrow
                throw error
            }
            
            await MainActor.run {
                let controller = UIAlertController(
                    title: Strings.Settings.Alert.importMediaConfirmTitle,
                    message: Strings.Settings.Alert.importMediaConfirmMessage(medias.count),
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
                        // Load the thumbnails now
                        Task(priority: .userInitiated) {
                            do {
                                try PersistenceController.viewContext.fetch(Media.fetchRequest())
                                    .forEach { $0.loadThumbnail() }
                            } catch {
                                Logger.library.error(
                                    // swiftlint:disable:next line_length
                                    "Error fetching medias for loading thumbnail after import: \(error, privacy: .public)"
                                )
                            }
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
}

#Preview {
    ImportMediaButton(config: .constant(.init()))
}
