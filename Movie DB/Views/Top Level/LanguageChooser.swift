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
    @EnvironmentObject private var config: JFConfig
    
    var proxy: Binding<String?> {
        .init(get: { config.language }, set: { config.language = $0 ?? "" })
    }
    
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
                VStack {
                    CalloutView(text: Strings.LanguageChooser.callout, type: .info)
                        .padding()
                    List(selection: proxy) {
                        ForEach(config.availableLanguages, id: \.self) { (code: String) in
                            Text(Locale.current.localizedString(forIdentifier: code) ?? code)
                                .tag(code)
                        }
                    }
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

#Preview {
    LanguageChooser()
        .previewEnvironment()
}
