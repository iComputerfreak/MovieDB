//
//  PreferencesSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import os.log
import SwiftUI

struct PreferencesSection: View {
    @EnvironmentObject var preferences: JFConfig
    @Binding var config: SettingsViewModel
    // We need to know how to reload the library if the language changes
    // swiftformat:disable:next spaceAroundParens
    let reloadHandler: @MainActor () -> Void
    
    @State private var reloadLibraryAlertShowing = false
    
    var body: some View {
        Section {
            Toggle(Strings.Settings.showAdultContentLabel, isOn: $preferences.showAdults)
            LanguagePickerView()
                .onChange(of: preferences.language) { languageCode in
                    Logger.settings.info("Language changed to \(languageCode, privacy: .public)")
                    self.config.languageChanged = true
                }
            RegionPickerView()
                .onChange(of: preferences.region) { regionCode in
                    Logger.settings.info("Region changed to \(regionCode, privacy: .public)")
                    self.config.regionChanged = true
                }
            DefaultWatchStatePicker()
        }
        .alert(
            Text(Strings.Settings.Alert.reloadLibraryTitle),
            isPresented: $reloadLibraryAlertShowing,
            actions: {
                Button(Strings.Generic.alertButtonNo) {}
                Button(Strings.Generic.alertButtonYes) {
                    self.reloadHandler()
                }
            },
            message: {
                Text(Strings.Settings.Alert.reloadLibraryMessage)
            }
        )
        .onDisappear {
            if self.config.languageChanged || self.config.regionChanged {
                self.reloadLibraryAlertShowing = true
                self.config.languageChanged = false
                self.config.regionChanged = false
            }
        }
    }
}

#Preview {
    List {
        PreferencesSection(
            config: .constant(SettingsViewModel()),
            reloadHandler: {}
        )
        .previewEnvironment()
    }
}
