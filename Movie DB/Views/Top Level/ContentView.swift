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
    @State private var problemsIgnored: Bool = false

    var body: some View {
        NotificationView { notificationProxy in
            Group {
                #if os(iOS)
                if #available(iOS 26, *) {
                    modernTabView
                } else {
                    legacyTabView
                }
                #else
                legacyTabView
                #endif
            }
            .environment(unifiedSearchCoordinator)
            .environment(notificationProxy)
            .onChange(of: unifiedSearchCoordinator.shouldOpenSearchTab) { _, shouldOpenSearchTab in
                guard shouldOpenSearchTab else { return }
                selectedTab = .search
                unifiedSearchCoordinator.shouldOpenSearchTab = false
            }
            .fullScreenCover(isPresented: .init(get: { !problems.isEmpty && !problemsIgnored })) {
                ResolveProblemsView(problems: $problems, ignoreProblems: { self.problemsIgnored = true })
                    .environment(\.managedObjectContext, PersistenceController.viewContext)
                    .environment(notificationProxy)
                    .environment(unifiedSearchCoordinator)
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

    #if os(iOS)
    @available(iOS 26, *)
    private var modernTabViewContent: some View {
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
    }

    @available(iOS 26, *)
    var modernTabView: some View {
        Group {
            if #available(iOS 26.1, *) {
                modernTabViewContent
                    .tabViewBottomAccessory(isEnabled: LibraryUpdateStatus.shared.isActive) {
                        LibraryUpdateBottomAccessory()
                    }
            } else {
                if LibraryUpdateStatus.shared.isActive {
                    modernTabViewContent
                        .tabViewBottomAccessory {
                            LibraryUpdateBottomAccessory()
                        }
                } else {
                    modernTabViewContent
                }
            }
        }
        .tabViewSearchActivation(.searchTabSelection)
    }
    #endif
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
