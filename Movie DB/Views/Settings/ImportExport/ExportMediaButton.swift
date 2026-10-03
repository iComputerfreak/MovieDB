// Copyright © 2023 Jonas Frey. All rights reserved.

import Analytics
import SwiftUI

struct ExportMediaButton: View {
    @Binding var config: SettingsViewModel
    @State private var error: (any Error)?
    
    var body: some View {
        Button(action: self.exportMedia) {
            SettingsActionLabel(
                title: Strings.Settings.exportMediaLabel,
                systemImage: "square.and.arrow.up.fill",
                tint: .orange
            )
        }
        .errorAlert(error: $error)
    }
    
    func exportMedia() {
        Task(priority: .userInitiated) {
            let mediaCount = MediaLibrary.shared.mediaCount() ?? 0

            await MainActor.run {
                config.isLoading = true
            }

            do {
                let exportedData = try await config.export(
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
                    config.exportedData = exportedData
                    AnalyticsService.shared.track(
                        .mediaExported(exportCountBucket: .bucket(for: mediaCount))
                    )
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
            await MainActor.run {
                config.isLoading = false
            }
        }
    }
}

#Preview {
    ExportMediaButton(config: .constant(.init()))
}
