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

enum ExportError: Error {
    case cannotConvertToData
}

struct ImportExportSection: View {
    @Binding var config: SettingsViewModel

    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext

    var isShowingFileExporterProxy: Binding<Bool> {
        Binding {
            config.exportedData != nil
        } set: { newValue in
            // Reset the URL if the sheet is dismissed
            if newValue == false {
                config.exportedData = nil
            }
        }
    }

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
        .fileExporter(
            isPresented: isShowingFileExporterProxy,
            item: config.exportedData?.data,
            defaultFilename: config.exportedData?.filename ?? "MovieDB_Export.csv",
            onCompletion: { _ in config.exportedData = nil }
        )
    }
    
    // TODO: Should be an async function without `isLoading`
    // Generic import function with a custom handler, does not save the changes.
    static func `import`(
        isLoading: Binding<Bool>,
        handler: @escaping (NSManagedObjectContext) async throws -> Void
    ) {
        // Use iOS file picker
        Logger.importExport.debug("Starting an import...")
        isLoading.wrappedValue = true
        
        // Create a new background context for importing the objects
        let importContext = PersistenceController.viewContext.newBackgroundContext()
        // Set the merge policy to not override existing data
        importContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        // Do the async work in a background task, but give it high priority, since the user is waiting for it to finish
        Task(priority: .high) {
            do {
                try await handler(importContext)
            } catch {
                Logger.importExport.error("Error during import: \(error, privacy: .public)")
                Task(priority: .userInitiated) {
                    await MainActor.run {
                        isLoading.wrappedValue = false
                        AlertHandler.showError(
                            title: Strings.Settings.Alert.genericImportErrorTitle,
                            error: error
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    List {
        ImportExportSection(config: .constant(SettingsViewModel()))
    }
}
