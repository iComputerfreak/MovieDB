// Copyright © 2022 Jonas Frey. All rights reserved.

import CoreData
import Analytics
import JFUtils
import SwiftUI

struct MediaListsRootView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext

    // MARK: Default Lists
    var defaultLists: [PredicateMediaList] {
        [
            PredicateMediaList.favorites,
            PredicateMediaList.watchlist,
            PredicateMediaList.problems,
        ]
    }
    
    // MARK: Dynamic Lists (predicate-based)
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name, order: .forward)]
    )
    private var dynamicLists: FetchedResults<DynamicMediaList>
    
    // MARK: User Lists (single objects)
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name, order: .forward)]
    )
    private var userLists: FetchedResults<UserMediaList>
    
    var allLists: [any MediaListProtocol] {
        defaultLists + Array(dynamicLists) + Array(userLists)
    }
    
    @State private var selectedMediaObjects: Set<Media> = []
    // Show the sidebar by default
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var isShowingNewListAlert = false
    @State private var isCreatingDynamicList = false
    @State private var newListName = ""
    @State private var duplicateListMessage: String?

    private var newListAlertTitle: String {
        isCreatingDynamicList ? Strings.Lists.Alert.newDynamicListTitle : Strings.Lists.Alert.newCustomListTitle
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List {
                // MARK: - Default Lists (disabled during editing)
                DefaultMediaListsSection(selectedMediaObjects: $selectedMediaObjects)

                // MARK: - Dynamic Lists
                if !dynamicLists.isEmpty {
                    Section(Strings.Lists.dynamicListsHeader) {
                        ForEach(dynamicLists) { list in
                            // NavigationLink for the lists
                            NavigationLink {
                                DynamicMediaListView(list: list, selectedMediaObjects: $selectedMediaObjects)
                            } label: {
                                ListRowLabel(list: list)
                            }
                        }
                        // List delete
                        .onDelete(perform: deleteDynamicList(indexSet:))
                    }
                }
                // MARK: - User Lists
                if !userLists.isEmpty {
                    Section(Strings.Lists.customListsHeader) {
                        ForEach(userLists) { list in
                            NavigationLink {
                                UserMediaListView(list: list, selectedMediaObjects: $selectedMediaObjects)
                            } label: {
                                ListRowLabel(list: list)
                            }
                        }
                        // List delete
                        .onDelete(perform: deleteUserList(indexSet:))
                    }
                }
            }
            .symbolVariant(.fill)
            .toolbar(content: toolbar)
            .navigationTitle(Strings.TabView.listsLabel)
        } content: {
            // MARK: List contents showing the medias in the list
            // content is provided by the `NavigationLink`s in the sidebar view
            Text(Strings.Lists.rootPlaceholderText)
        } detail: {
            // TODO: We should separate the selected objects from the different lists here
            NavigationStack {
                // MARK: MediaDetail
                if selectedMediaObjects.count == 1, let selectedMedia = selectedMediaObjects.first {
                    MediaDetail()
                        .environmentObject(selectedMedia)
                } else if selectedMediaObjects.count > 1 {
                    Text(Strings.Generic.multipleObjectsSelected)
                } else {
                    Text(Strings.Lists.detailPlaceholderText)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .alert(newListAlertTitle, isPresented: $isShowingNewListAlert) {
            TextField(newListAlertTitle, text: $newListName)
            Button(Strings.Generic.alertButtonCancel, role: .cancel) {}
            Button(Strings.Lists.Alert.newListButtonAdd, action: createList)
                .disabled(newListName.trimmingCharacters(in: .whitespaces).isEmpty)
        } message: {
            Text(Strings.Lists.Alert.newListMessage)
        }
        .messageAlert(title: Strings.Lists.Alert.alreadyExistsTitle, message: $duplicateListMessage)
        .onAppear {
            AnalyticsService.shared.track(.screenViewed(screenName: .mediaLists))
        }
    }
    
    private func deleteDynamicList(indexSet: IndexSet) {
        for index in indexSet {
            let list = dynamicLists[index]
            AnalyticsService.shared.track(
                .dynamicListDeleted(predicateType: list.filterSetting?.analyticsPrimaryFilterType ?? .unconfigured)
            )
            self.managedObjectContext.delete(dynamicLists[index])
        }
        PersistenceController.saveContext(managedObjectContext)
    }
    
    private func deleteUserList(indexSet: IndexSet) {
        for index in indexSet {
            AnalyticsService.shared.track(.customListDeleted)
            self.managedObjectContext.delete(userLists[index])
        }
        PersistenceController.saveContext(managedObjectContext)
    }
    
    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            // !!!: Only used for deleting lists (maybe later reordering), not configuring them!
            #if os(iOS)
            EditButton()
            #endif
        }
        ToolbarItem(placement: .secondaryAction) {
            Menu(Strings.Lists.newListLabel) {
                Button(Strings.Lists.newDynamicListLabel) {
                    isCreatingDynamicList = true
                    newListName = ""
                    isShowingNewListAlert = true
                }
                .accessibilityIdentifier("new-dynamic-list")
                Button(Strings.Lists.newCustomListLabel) {
                    isCreatingDynamicList = false
                    newListName = ""
                    isShowingNewListAlert = true
                }
                .accessibilityIdentifier("new-custom-list")
            }
            .accessibilityIdentifier("new-list")
        }
    }
    
    /// Creates a list from current alert input when its name is unique.
    private func createList() {
        let name = newListName.trimmingCharacters(in: .whitespaces)
        guard !allLists.map(\.name).contains(where: { $0.localizedCaseInsensitiveCompare(name) == .orderedSame }) else {
            Task { @MainActor in
                // Let the text-entry alert dismiss before presenting the duplicate-name alert.
                await Task.yield()
                duplicateListMessage = Strings.Lists.Alert.alreadyExistsMessage(name)
            }
            return
        }

        if isCreatingDynamicList {
            let list = DynamicMediaList(context: managedObjectContext)
            list.name = name
            AnalyticsService.shared.track(.dynamicListCreated(predicateType: .unconfigured))
        } else {
            let list = UserMediaList(context: managedObjectContext)
            list.name = name
            AnalyticsService.shared.track(.customListCreated)
        }
        PersistenceController.saveContext(managedObjectContext)
    }
}

#Preview {
    MediaListsRootView()
        .previewEnvironment()
}
