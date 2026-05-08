// Copyright © 2019 Jonas Frey. All rights reserved.

import SwiftUI

struct ContentView: View {
    private enum RootTab: Hashable {
        case library
        case lists
        case search
        case settings
    }

    @State private var problems = MediaLibrary.shared.problems()
    @State private var selectedTab: RootTab = .library
    @State private var unifiedSearchCoordinator = UnifiedSearchCoordinator()

    var body: some View {
        NotificationView { notificationProxy in
            Group {
                if #available(iOS 26, *) {
                    modernTabView
                } else {
                    legacyTabView
                }
            }
            .environment(unifiedSearchCoordinator)
            .environmentObject(notificationProxy)
            .onChange(of: unifiedSearchCoordinator.shouldOpenSearchTab) { _, shouldOpenSearchTab in
                guard shouldOpenSearchTab else { return }
                selectedTab = .search
                unifiedSearchCoordinator.shouldOpenSearchTab = false
            }
            .fullScreenCover(isPresented: .init(get: { !problems.isEmpty })) {
                ResolveProblemsView(problems: $problems)
                    .environment(\.managedObjectContext, PersistenceController.viewContext)
            }
        }
    }

    var legacyTabView: some View {
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

            UnifiedSearchView()
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
    }

    @available(iOS 26, *)
    var modernTabView: some View {
        TabView(selection: $selectedTab) {
            Tab(Strings.TabView.libraryLabel, systemImage: "film", value: .library) {
                LibraryHome()
            }

            Tab(Strings.TabView.listsLabel, systemImage: "list.bullet", value: .lists) {
                MediaListsRootView()
            }

            Tab(Strings.TabView.settingsLabel, systemImage: "gear", value: .settings) {
                SettingsView()
            }

            Tab(value: RootTab.search, role: .search) {
                UnifiedSearchView()
            }
        }
        .tabViewSearchActivation(.searchTabSelection)
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
