//
//  LanguageChooser.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import SwiftUI

struct LanguageChooser: View {
    
    @ObservedObject private var config: JFConfig = JFConfig.shared
    
    // TODO: Localize file
    
    init() {
        // Load the available langugages from TMDB
        if config.availableLanguages.isEmpty {
            Utils.updateTMDBLanguages()
        }
    }
    
    var body: some View {
        NavigationView {
            if config.availableLanguages.isEmpty {
                Text("Loading Languages...")
                    .navigationTitle("Select Language")
            } else {
                let proxy = Binding<String?>(get: { return config.language }, set: { newValue in config.language = newValue ?? "" })
                List(config.availableLanguages, id: \.self, selection: proxy, rowContent: { (code: String) in
                    Text(Locale.current.localizedString(forIdentifier: code) ?? code)
                        .tag(code)
                })
                .environment(\.editMode, .constant(.active))
                .onChange(of: config.language) { newValue in
                    print("Language changed to \(config.language)")
                }
                .navigationTitle("Select Language")
            }
        }
    }
}

struct LanguageChooser_Previews: PreviewProvider {
    static var previews: some View {
        LanguageChooser()
    }
}
