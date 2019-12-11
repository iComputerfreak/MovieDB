//
//  SettingsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    // Reference to the config instance
    @ObservedObject private var config: JFConfig = JFConfig.shared
    
    init() {
    }
    
    func save() {
    }
    
    // TODO: Reload all media objects when changing region / Language?
    var sortedLanguages: [String] {
        Locale.isoLanguageCodes.sorted { (code1, code2) -> Bool in
            // Sort nil values to the end
            guard let language1 = JFUtils.languageString(for: code1) else {
                return false
            }
            guard let language2 = JFUtils.languageString(for: code2) else {
                return true
            }
            return language1.lexicographicallyPrecedes(language2)
        }
    }
    
    var sortedRegions: [String] {
        Locale.isoRegionCodes.sorted { (code1, code2) -> Bool in
            // Sort nil values to the end
            guard let region1 = JFUtils.regionString(for: code1) else {
                return false
            }
            guard let region2 = JFUtils.regionString(for: code2) else {
                return true
            }
            return region1.lexicographicallyPrecedes(region2)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Toggle(isOn: $config.showAdults, label: { Text("Show Adult Content") })
                Picker("Database Language", selection: $config.language) {
                    ForEach(self.sortedLanguages, id: \.self) { code in
                        Text(JFUtils.languageString(for: code) ?? code)
                            .tag(code)
                    }
                }
                Picker("Region", selection: $config.region) {
                    ForEach(self.sortedRegions, id: \.self) { code in
                        Text(JFUtils.regionString(for: code) ?? code)
                            .tag(code)
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
        .onDisappear(perform: save)
    }
    
    struct Keys {
        static let showAdults = "showAdults"
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
