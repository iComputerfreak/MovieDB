//
//  ExportMediaButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ExportMediaButton: View {
    @Binding var config: SettingsViewConfig
    
    var body: some View {
        Button(Strings.Settings.exportMediaLabel, action: self.exportMedia)
    }
    
    func exportMedia() {
        ImportExportSection.export(
            filename: "MovieDB_Export_\(Utils.isoDateString()).csv",
            isLoading: $config.isLoading
        ) { context in
            let medias = Utils.allMedias(context: context)
            return CSVManager.createCSV(from: medias)
        }
    }
}

struct ExportMediaButton_Previews: PreviewProvider {
    static var previews: some View {
        ExportMediaButton(config: .constant(.init()))
    }
}
