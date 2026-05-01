// Copyright © 2023 Jonas Frey. All rights reserved.

import Analytics
import SwiftUI

struct ExportMediaButton: View {
    @Binding var config: SettingsViewModel
    
    var body: some View {
        Button(action: self.exportMedia) {
            SettingsActionLabel(
                title: Strings.Settings.exportMediaLabel,
                systemImage: "square.and.arrow.up.fill",
                tint: .orange
            )
        }
    }
    
    func exportMedia() {
        Task(priority: .userInitiated) {
            let mediaCount = MediaLibrary.shared.mediaCount() ?? 0

            await MainActor.run {
                config.isLoading = true
            }

            let exportedData = await config.export(
                filename: "MovieDB_Export_\(Utils.isoDateString()).csv",
                operation: .mediaExport
            ) { context in
                let medias = Utils.allMedias(context: context)
                let exporter = CSVExporter()
                guard let exportData = exporter.createCSV(from: medias).data(using: .utf8) else {
                    throw SettingsViewModel.ExportFailure.failed(.mediaExport, .contentGeneration)
                }
                return exportData
            }

            await MainActor.run {
                config.isLoading = false
                config.exportedData = exportedData
                if exportedData != nil {
                    AnalyticsService.shared.track(
                        .mediaExported(exportCountBucket: .bucket(for: mediaCount))
                    )
                }
            }
        }
    }
}

#Preview {
    ExportMediaButton(config: .constant(.init()))
}
