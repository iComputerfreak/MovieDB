//
//  SettingsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    // Settings
    @State private var showAdults: Bool
    
    init() {
        // Load settings
        let defaults = UserDefaults.standard
        self._showAdults = State(wrappedValue: defaults.bool(forKey: Keys.showAdults))
    }
    
    func save() {
        // Save settings
        let defaults = UserDefaults.standard
        defaults.set(self.showAdults, forKey: Keys.showAdults)
        print("Settings saved.")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Toggle(isOn: $showAdults, label: { Text("Show Adult Content") })
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
