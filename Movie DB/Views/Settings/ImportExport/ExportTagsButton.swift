//
//  ExportTagsButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Analytics
import SwiftUI

struct ExportTagsButton: View {
    @Binding var config: SettingsViewModel
    
    var body: some View {
        Button(action: self.exportTags) {
            SettingsActionLabel(
                title: Strings.Settings.exportTagsLabel,
                systemImage: "arrow.up.circle.fill",
                tint: .pink
            )
        }
    }
    
    func exportTags() {
        Task(priority: .userInitiated) {
            await MainActor.run {
                config.isLoading = true
            }

            let exportedData = await config.export(
                filename: "MovieDB_Tags_Export_\(Utils.isoDateString()).txt"
            ) { context in
                let exportContent = try TagImporter.export(context: context)
                guard let exportData = exportContent.data(using: .utf8) else { throw ExportError.cannotConvertToData }
                return exportData
            }

            await MainActor.run {
                config.isLoading = false
                config.exportedData = exportedData
                if let exportedData {
                    let tagCount = String(decoding: exportedData.data, as: UTF8.self)
                        .components(separatedBy: .newlines)
                        .filter(\.isNotEmpty)
                        .count
                    AnalyticsService.shared.track(
                        .tagsExported(exportCountBucket: .bucket(for: tagCount))
                    )
                }
            }
        }
    }
}

#Preview {
    ExportTagsButton(config: .constant(.init()))
}
