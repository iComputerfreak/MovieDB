// Copyright © 2022 Jonas Frey. All rights reserved.

import Analytics
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
        Section(Strings.Settings.preferencesSectionHeader) {
            Toggle(Strings.Settings.showAdultContentLabel, isOn: $preferences.showAdults)
                .onChange(of: preferences.showAdults) { _, newValue in
                    AnalyticsService.shared.track(
                        .settingChanged(settingKey: .showAdults, newValue: .boolean(newValue))
                    )
                }
            LanguagePickerView()
                .onChange(of: preferences.language) { _, languageCode in
                    Logger.settings.info("Language changed to \(languageCode, privacy: .public)")
                    self.config.languageChanged = true
                    AnalyticsService.shared.track(
                        .settingChanged(settingKey: .language, newValue: .string(languageCode))
                    )
                }
            RegionPickerView()
                .onChange(of: preferences.region) { _, regionCode in
                    Logger.settings.info("Region changed to \(regionCode, privacy: .public)")
                    self.config.regionChanged = true
                    AnalyticsService.shared.track(
                        .settingChanged(settingKey: .region, newValue: .string(regionCode))
                    )
                }
            DefaultWatchStatePicker()
                .onChange(of: preferences.defaultWatchState) { _, newValue in
                    AnalyticsService.shared.track(
                        .settingChanged(settingKey: .defaultWatchState, newValue: .string(newValue.rawValue))
                    )
                }
            SubtitleContentPicker(subtitleContent: Binding($preferences.defaultSubtitleContent))
                .onChange(of: preferences.defaultSubtitleContent) { _, newValue in
                    AnalyticsService.shared.track(
                        .settingChanged(
                            settingKey: .defaultSubtitleContent,
                            newValue: .string(newValue.rawValue)
                        )
                    )
                }
            NavigationLink {
                WatchProvidersPicker()
            } label: {
                Text(Strings.Settings.watchProviderSettingsLabel)
            }
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
