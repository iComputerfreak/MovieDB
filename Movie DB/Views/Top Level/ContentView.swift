// Copyright © 2019 Jonas Frey. All rights reserved.

import SwiftUI
import TipKit

struct LibraryRowSettingsTip: Tip {
    let title = Text(Strings.Tips.libraryRowTipTitle)
    let message: Text? = Text(Strings.Tips.libraryRowTipMessage)
}

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
            .background(alignment: .bottomTrailing) {
                tabBarTipBackground
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

            Tab(value: RootTab.search, role: .search) {
                UnifiedSearchView()
            }

            Tab(Strings.TabView.settingsLabel, systemImage: "gear", value: .settings) {
                SettingsView()
            }
        }
        .tabViewSearchActivation(.searchTabSelection)
    }

    var tabBarTipBackground: some View {
        HStack(spacing: 0) {
            Color.clear
            Color.clear
            Color.clear
            Color.clear
                .popoverTip(LibraryRowSettingsTip(), arrowEdge: .bottom)
        }
        .frame(height: 50)
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
