//
//  ExportMediaButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import os.log
import SwiftUI

struct ExportMediaButton: View {
    @Binding var config: SettingsViewModel
    
    var body: some View {
        Button(Strings.Settings.exportMediaLabel, action: self.exportMedia)
    }
    
    func exportMedia() {
        Task(priority: .high) {
            // TODO: Maybe declare isLoading as @MainActor? Or even config?
            await MainActor.run {
                self.config.isLoading = true
            }
            do {
                try await ImportExportSection.export(
                    filename: "MovieDB_Export_\(Utils.isoDateString()).csv"
                ) { context in
                    let medias = Utils.allMedias(context: context)
                    let exporter = CSVExporter()
                    return exporter.createCSV(from: medias)
                }
            } catch {
                Logger.importExport.error("Error writing export file: \(error, privacy: .public)")
                // Stop the loading animation
            }
            await MainActor.run {
                self.config.isLoading = false
            }
        }
    }
}

struct ExportMediaButton_Previews: PreviewProvider {
    static var previews: some View {
        ExportMediaButton(config: .constant(.init()))
    }
}
