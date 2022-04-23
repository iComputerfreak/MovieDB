//
//  PreferencesSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct PreferencesSection: View {
    @EnvironmentObject var preferences: JFConfig
    @EnvironmentObject var library: MediaLibrary
    @Binding var config: SettingsViewConfig
    // We need to know how to reload the library if the language changes
    let reloadHandler: () -> Void
    
    var body: some View {
        Section {
            Toggle("Show Adult Content", isOn: $preferences.showAdults)
            LanguagePickerView()
                .onChange(of: preferences.language) { languageCode in
                    print("Language changed to \(languageCode)")
                    self.config.languageChanged = true
                }
        }
        .onDisappear {
            if self.config.languageChanged {
                AlertHandler.showYesNoAlert(
                    title: NSLocalizedString("Reload library?"),
                    message: NSLocalizedString("Do you want to reload all media objects using the new language?"),
                    yesAction: { _ in self.reloadHandler() }
                )
                self.config.languageChanged = false
            }
        }
    }
}

struct PreferencesSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PreferencesSection(
                config: .constant(SettingsViewConfig()),
                reloadHandler: {}
            )
            .environmentObject(JFConfig.shared)
        }
    }
}
