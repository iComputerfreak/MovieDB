//
//  ExportTagsButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ExportTagsButton: View {
    @Binding var config: SettingsViewConfig
    
    var body: some View {
        Button(Strings.Settings.exportTagsLabel, action: self.exportTags)
    }
    
    func exportTags() {
        ImportExportSection.export(
            filename: "MovieDB_Tags_Export_\(Utils.isoDateString()).txt",
            isLoading: $config.isLoading
        ) { context in
            try TagImporter.export(context: context)
        }
    }
}

struct ExportTagsButton_Previews: PreviewProvider {
    static var previews: some View {
        ExportTagsButton(config: .constant(.init()))
    }
}
