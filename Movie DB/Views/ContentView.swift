//
//  ContentView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    
    var body: some View {
        TabView {
            LibraryHome()
                .tabItem {
                    Image(systemName: "film")
                    Text("Home")
                }
            
            if MediaLibrary.shared.hasProblems {
                ProblemsView()
                    .tabItem {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Problems")
                    }
            }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
