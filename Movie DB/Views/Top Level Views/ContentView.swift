//
//  ContentView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var config: JFConfig = JFConfig.shared
    @StateObject private var storeManager = StoreManager.shared
    
    var body: some View {
        TabView {
            LibraryHome()
                .tabItem {
                    Image(systemName: "film")
                    Text("Library")
                }
            
            ProblemsView()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Problems")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .fullScreenCover(isPresented: .init(get: { self.config.language.isEmpty }, set: { _ in })) {
            LanguageChooser()
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
