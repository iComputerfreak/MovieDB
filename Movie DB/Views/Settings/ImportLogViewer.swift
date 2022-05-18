//
//  ImportLogViewer.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct ImportLogViewer: View {
    let logger: TagImporter.BasicLogger
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Text(logger.log)
                        .lineLimit(nil)
                        .padding()
                        .font(.footnote)
                    Spacer()
                }
                Spacer()
            }
            .navigationTitle(String(
                localized: "settings.importLog.navBar.title",
                comment: "The navigation bar title for the import log that is being shown after importing media"
            ))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(
                        localized: "settings.importLog.navBar.button.close",
                        comment: "The label for the close button in the navigation bar of the settings' import log"
                    )) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(
                        localized: "settings.importLog.navBar.button.copy",
                        comment: "The label for the copy button in the navigation bar of the settings' import log"
                    )) {
                        UIPasteboard.general.string = logger.log
                    }
                }
            }
        }
    }
}

struct ImportLogViewer_Previews: PreviewProvider {
    static var logger: TagImporter.BasicLogger {
        let l = TagImporter.BasicLogger()
        l.info("Import started")
        l.debug("Progress: 10%")
        l.debug("Progress: 20%")
        l.debug("Progress: 30%")
        l.debug("Progress: 40%")
        l.debug("Progress: 50%")
        l.debug("Progress: 60%")
        l.debug("Progress: 70%")
        l.debug("Progress: 80%")
        l.warn("Missing import key: tmdbID. Skipping...")
        l.critical("Error reading file!")
        return l
    }
    
    static var previews: some View {
        ImportLogViewer(logger: logger)
    }
}
