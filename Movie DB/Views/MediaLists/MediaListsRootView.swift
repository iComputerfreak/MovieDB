//
//  MediaListsRootView.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import JFUtils
import SwiftUI

struct MediaListsRootView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.editMode) private var editMode
    
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
                                ListRowLabel(
                                    list: list,
                                    iconColor: Color(list.iconColor ?? .primaryIcon),
                                    symbolRenderingMode: list.iconRenderingMode.symbolRenderingMode
                                )
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
                                ListRowLabel(
                                    list: list,
                                    iconColor: Color(list.iconColor ?? .primaryIcon),
                                    symbolRenderingMode: list.iconRenderingMode.symbolRenderingMode
                                )
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
    }
    
    private func deleteDynamicList(indexSet: IndexSet) {
        for index in indexSet {
            self.managedObjectContext.delete(dynamicLists[index])
        }
        PersistenceController.saveContext(managedObjectContext)
    }
    
    private func deleteUserList(indexSet: IndexSet) {
        for index in indexSet {
            self.managedObjectContext.delete(userLists[index])
        }
        PersistenceController.saveContext(managedObjectContext)
    }
    
    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            // !!!: Only used for deleting lists (maybe later reordering), not configuring them!
            EditButton()
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Menu(Strings.Lists.newListLabel) {
                Button(Strings.Lists.newDynamicListLabel) {
                    let alert = buildAlert(Strings.Lists.Alert.newDynamicListTitle) { name in
                        let list = DynamicMediaList(context: managedObjectContext)
                        list.name = name
                        PersistenceController.saveContext(managedObjectContext)
                    }
                    AlertHandler.presentAlert(alert: alert)
                }
                .accessibilityIdentifier("new-dynamic-list")
                Button(Strings.Lists.newCustomListLabel) {
                    let alert = buildAlert(Strings.Lists.Alert.newCustomListTitle) { name in
                        let list = UserMediaList(context: managedObjectContext)
                        list.name = name
                        PersistenceController.saveContext(managedObjectContext)
                    }
                    AlertHandler.presentAlert(alert: alert)
                }
                .accessibilityIdentifier("new-custom-list")
            }
            .accessibilityIdentifier("new-list")
        }
    }
    
    private func buildAlert(_ title: String, onSubmit: @escaping (String) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: Strings.Lists.Alert.newListMessage, preferredStyle: .alert)
        alert.addTextField { $0.autocapitalizationType = .words }
        alert.addAction(.cancelAction())
        alert.addAction(.init(title: Strings.Lists.Alert.newListButtonAdd, style: .default, handler: { _ in
            guard let textField = alert.textFields?.first else { return }
            guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return }
            // Check on equality, ignoring case
            guard !allLists.map(\.name).map({ $0.lowercased() }).contains(text.lowercased()) else {
                AlertHandler.showSimpleAlert(
                    title: Strings.Lists.Alert.alreadyExistsTitle,
                    message: Strings.Lists.Alert.alreadyExistsMessage(text)
                )
                return
            }
            onSubmit(text)
        }))
        return alert
    }
}

#Preview {
    MediaListsRootView()
        .previewEnvironment()
}
