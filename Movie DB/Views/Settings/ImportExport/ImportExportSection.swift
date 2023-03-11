//
//  ImportExportSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import os.log
import SwiftUI

struct ImportExportSection: View {
    @Binding var config: SettingsViewConfig
    
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    
    var body: some View {
        Section {
            // MARK: - Import Button
            ImportMediaButton(config: $config)
            
            // MARK: - Export Button
            ExportMediaButton(config: $config)
            
            // MARK: - Import Tags
            ImportTagsButton(config: $config)
            
            // MARK: - Export Tags
            ExportTagsButton(config: $config)
        }
        // MARK: Import Log Popover
        .sheet(isPresented: $config.importLogShowing) {
            if let logger = $config.importLogger.wrappedValue {
                ImportLogViewer(logger: logger)
            } else {
                EmptyView()
            }
        }
    }
    
    // Generic import function with a custom handler, does not save the changes.
    static func `import`(
        isLoading: Binding<Bool>,
        handler: @escaping (NSManagedObjectContext) throws -> Void
    ) {
        // Use iOS file picker
        Logger.importExport.debug("Starting an import...")
        isLoading.wrappedValue = true
        
        // Perform the import into a separate context on a background thread
        PersistenceController.shared.container.performBackgroundTask { (importContext: NSManagedObjectContext) in
            // Set the merge policy to not override existing data
            importContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            importContext.type = .backgroundContext
            do {
                try handler(importContext)
            } catch {
                Logger.importExport.error("Error during import: \(error, privacy: .public)")
                AlertHandler.showError(
                    title: Strings.Settings.Alert.genericImportErrorTitle,
                    error: error
                )
                Task(priority: .userInitiated) {
                    await MainActor.run {
                        isLoading.wrappedValue = false
                    }
                }
            }
        }
    }
    
    static func export(
        filename: String,
        isLoading: Binding<Bool>,
        content: @escaping (NSManagedObjectContext) throws -> String
    ) {
        Logger.importExport.debug("Exporting \(filename, privacy: .public)...")
        isLoading.wrappedValue = true
        
        Task(priority: .userInitiated) {
            await PersistenceController.shared.container.performBackgroundTask { context in
                context.type = .backgroundContext
                do {
                    // Get the content to export
                    let exportData: String = try content(context)
                    // Save as a file to share it
                    guard let url = Utils.documentsPath?.appendingPathComponent(filename) else {
                        Task(priority: .userInitiated) {
                            await MainActor.run {
                                AlertHandler.showSimpleAlert(
                                    title: Strings.Settings.Alert.genericExportErrorTitle,
                                    message: Strings.Settings.Alert.genericExportErrorMessage
                                )
                            }
                        }
                        return
                    }
                    try exportData.write(to: url, atomically: true, encoding: .utf8)
                    Utils.share(items: [url])
                } catch {
                    Logger.importExport.error("Error writing export file: \(error, privacy: .public)")
                    // Stop the loading animation
                    Task(priority: .userInitiated) {
                        await MainActor.run {
                            isLoading.wrappedValue = false
                        }
                    }
                    return
                }
                Task(priority: .userInitiated) {
                    await MainActor.run {
                        isLoading.wrappedValue = false
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
