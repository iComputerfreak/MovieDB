//
//  ContentView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var config = JFConfig.shared
    @StateObject private var storeManager = StoreManager.shared
    
    @State private var problems = MediaLibrary.shared.problems()
    
    var body: some View {
        TabView {
            LibraryHome()
                .tabItem {
                    Image(systemName: "film")
                    Text("Library")
                }
            LookupView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Lookup")
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
