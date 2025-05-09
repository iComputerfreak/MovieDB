//
//  ExportMediaButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ExportMediaButton: View {
    @Binding var config: SettingsViewModel
    
    var body: some View {
        Button(Strings.Settings.exportMediaLabel, action: self.exportMedia)
    }
    
    func exportMedia() {
        Task(priority: .userInitiated) {
            await MainActor.run {
                config.isLoading = true
            }

            let exportedData = await config.export(
                filename: "MovieDB_Export_\(Utils.isoDateString()).csv"
            ) { context in
                let medias = Utils.allMedias(context: context)
                let exporter = CSVExporter()
                guard let exportData = exporter.createCSV(from: medias).data(using: .utf8) else {
                    throw ExportError.cannotConvertToData
                }
                return exportData
            }

            await MainActor.run {
                config.isLoading = false
                config.exportedData = exportedData
            }
        }
    }
}

#Preview {
    ExportMediaButton(config: .constant(.init()))
}
