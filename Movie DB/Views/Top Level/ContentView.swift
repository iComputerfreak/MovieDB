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
                    Text(
                        "tabView.library.label",
                        comment: "The label of the library tab of the main TabView"
                    )
                }
            LookupView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text(
                        "tabView.lookup.label",
                        comment: "The label of the lookup tab of the main TabView"
                    )
                }
            
            ProblemsView()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle")
                    Text(
                        "tabView.problems.label",
                        comment: "The label of the problems tab of the main TabView"
                    )
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(
                        "tabView.settings.label",
                        comment: "The label of the settings tab of the main TabView"
                    )
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
