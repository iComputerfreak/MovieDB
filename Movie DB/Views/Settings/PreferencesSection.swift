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
    @Binding var config: SettingsViewConfig
    // We need to know how to reload the library if the language changes
    let reloadHandler: () -> Void
    
    var body: some View {
        Section {
            Toggle(String(
                localized: "settings.toggle.showAdultContent.label",
                comment: "The label of the toggle in the settings that allows the user to specify whether the search results and library should include adult content"
            ), isOn: $preferences.showAdults)
            LanguagePickerView()
                .onChange(of: preferences.language) { languageCode in
                    print("Language changed to \(languageCode)")
                    self.config.languageChanged = true
                }
            RegionPickerView()
                .onChange(of: preferences.region) { regionCode in
                    print("Region changed to \(regionCode)")
                    self.config.regionChanged = true
                }
        }
        .onDisappear {
            if self.config.languageChanged || self.config.regionChanged {
                AlertHandler.showYesNoAlert(
                    title: String(
                        localized: "settings.alert.reloadLibrary.title",
                        comment: "Title of an alert asking the user for confirmation to reload the library"
                    ),
                    message: String(
                        localized: "settings.alert.reloadLibrary.message",
                        // No way to split up a StaticString into multiple lines
                        // swiftlint:disable:next line_length
                        comment: "Message of an alert asking the user for confirmation to reload the library after changing the language or region"
                    ),
                    yesAction: { _ in self.reloadHandler() }
                )
                self.config.languageChanged = false
                self.config.regionChanged = false
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
