//
//  ExportTagsButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import os.log
import SwiftUI

struct ExportTagsButton: View {
    @Binding var config: SettingsViewModel
    
    var body: some View {
        Button(Strings.Settings.exportTagsLabel, action: self.exportTags)
    }
    
    func exportTags() {
        Task(priority: .high) {
            // TODO: Maybe declare isLoading as @MainActor? Or even config?
            await MainActor.run {
                self.config.isLoading = true
            }
            do {
                try await ImportExportSection.export(
                    filename: "MovieDB_Tags_Export_\(Utils.isoDateString()).txt"
                ) { context in
                    try TagImporter.export(context: context)
                }
            } catch {
                Logger.importExport.error("Error writing export file: \(error, privacy: .public)")
            }
            await MainActor.run {
                self.config.isLoading = false
            }
        }
    }
}

struct ExportTagsButton_Previews: PreviewProvider {
    static var previews: some View {
        ExportTagsButton(config: .constant(.init()))
    }
}
