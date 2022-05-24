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
            .navigationTitle(Strings.Settings.importLogNavBarTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Strings.Settings.importLogNavBarButtonClose) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Strings.Settings.importLogNavBarButtonCopy) {
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
