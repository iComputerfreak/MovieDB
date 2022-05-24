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
                    Text(Strings.TabView.libraryLabel)
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
