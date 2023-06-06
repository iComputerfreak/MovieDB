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
    @Binding var config: SettingsViewModel
    
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
        handler: @escaping (NSManagedObjectContext) async throws -> Void
    ) async rethrows {
        // Use iOS file picker
        Logger.importExport.debug("Starting an import...")
        // Create a new background context for importing the objects
        let importContext = PersistenceController.viewContext.newBackgroundContext()
        // Set the merge policy to not override existing data
        importContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        // Do the async work in a background task, but give it high priority, since the user is waiting for it to finish
        try await handler(importContext)
    }
    
    static func export(
        filename: String,
        content: @escaping (NSManagedObjectContext) throws -> String
    ) async throws {
        Logger.importExport.debug("Exporting \(filename, privacy: .public)...")
        
        try await PersistenceController.shared.container.performBackgroundTask { context in
            context.type = .backgroundContext
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
        }
    }
}

struct ImportExportSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ImportExportSection(config: .constant(SettingsViewModel()))
        }
    }
}
