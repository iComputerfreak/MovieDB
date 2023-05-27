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
                    // TODO: Make a CalloutView that displays an icon (e.g. info.circle in blue) next to the text on a gray rounded rect background
                    Text(Strings.LanguageChooser.callout)
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical)
                        .padding(.horizontal, 16)
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

struct LanguageChooser_Previews: PreviewProvider {
    static var previews: some View {
        LanguageChooser()
            .previewEnvironment()
    }
}
