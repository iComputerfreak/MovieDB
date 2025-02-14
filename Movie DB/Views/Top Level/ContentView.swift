//
//  ContentView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import TipKit

struct LibraryRowSettingsTip: Tip {
    let title = Text(Strings.Tips.libraryRowTipTitle)
    let message: Text? = Text(Strings.Tips.libraryRowTipMessage)
}

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
            .background(alignment: .bottomTrailing) {
                HStack(spacing: 0) {
                    Color.clear
                    Color.clear
                    Color.clear
                    Color.clear
                        .popoverTip(LibraryRowSettingsTip(), arrowEdge: .bottom)
                }
                .frame(height: 50)
            }
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
