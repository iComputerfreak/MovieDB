//
//  LanguageChooser.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import os.log
import SwiftUI

struct LanguageChooser: View {
    @ObservedObject private var config = JFConfig.shared
    
    var body: some View {
        NavigationStack {
            if config.availableLanguages.isEmpty {
                Text(Strings.LanguageChooser.loadingText)
                    .task(priority: .userInitiated) {
                        do {
                            try await Utils.updateTMDBLanguages()
                        } catch {
                            AlertHandler.showError(
                                title: Strings.LanguageChooser.Alert.errorLoadingTitle,
                                error: error
                            )
                        }
                    }
                    .navigationTitle(Strings.LanguageChooser.navBarTitle)
            } else {
                let proxy = Binding<String?>(get: { config.language }, set: { config.language = $0 ?? "" })
                List(config.availableLanguages, id: \.self, selection: proxy) { (code: String) in
                    Text(Locale.current.localizedString(forIdentifier: code) ?? code)
                        .tag(code)
                }
                .environment(\.editMode, .constant(.active))
                .onChange(of: config.language) { _ in
                    Logger.settings.info("Language changed to \(config.language, privacy: .public)")
                }
                .navigationTitle(Strings.LanguageChooser.navBarTitle)
            }
        }
    }
}

struct LanguageChooser_Previews: PreviewProvider {
    static var previews: some View {
        LanguageChooser()
    }
}
