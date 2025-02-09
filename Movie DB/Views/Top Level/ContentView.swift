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
        NotificationView { notificationProxy in
            TabView {
                LibraryHome()
                    .tabItem {
                        Image(systemName: "film")
                        Text(Strings.TabView.libraryLabel)
                    }
                
                MediaListsRootView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text(Strings.TabView.listsLabel)
                    }
                
                LookupView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text(Strings.TabView.lookupLabel)
                    }
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text(Strings.TabView.settingsLabel)
                    }
            }
            .environmentObject(notificationProxy)
            .fullScreenCover(isPresented: .init(get: { !problems.isEmpty })) {
                ResolveProblemsView(problems: $problems)
                    .environment(\.managedObjectContext, PersistenceController.viewContext)
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
