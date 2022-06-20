//
//  ContentView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var problems = MediaLibrary.shared.problems()
    
    var body: some View {
        TabView {
            LibraryHome()
                .tabItem {
                    Image(systemName: "film")
                    Text(Strings.TabView.libraryLabel)
                }
            
            UserListsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text(Strings.TabView.listsLabel)
                }
            
            LookupView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text(Strings.TabView.lookupLabel)
                }
            
            ProblemsView()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle")
                    Text(Strings.TabView.problemsLabel)
                }
            
            #if DEBUG
            DebugView()
                .tabItem {
                    Image(systemName: "ladybug")
                    Text("Debug")
                }
            #endif
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(Strings.TabView.settingsLabel)
                }
        }
        .fullScreenCover(isPresented: .init(get: { !problems.isEmpty })) {
            ResolveProblemsView(problems: $problems)
                .environment(\.managedObjectContext, PersistenceController.viewContext)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
