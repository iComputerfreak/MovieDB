//
//  UserListsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
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
        entity: DynamicMediaList.entity(),
        sortDescriptors: [NSSortDescriptor(key: Schema.DynamicMediaList.name.rawValue, ascending: true)]
    ) private var dynamicLists: FetchedResults<DynamicMediaList>
    
    // MARK: User Lists (single objects)
    @FetchRequest(
        entity: UserMediaList.entity(),
        sortDescriptors: [NSSortDescriptor(key: Schema.UserMediaList.name.rawValue, ascending: true)]
    ) private var userLists: FetchedResults<UserMediaList>
    
    var allLists: [any MediaListProtocol] {
        var lists: [any MediaListProtocol] = defaultLists
        dynamicLists.forEach { lists.append($0) }
        userLists.forEach { lists.append($0) }
        return lists
    }
    
    @State private var selectedMedia: Media?
    // Show the sidebar by default
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView {
            List {
                // MARK: - Default Lists (disabled during editing)
                Section(Strings.Lists.defaultListsHeader) {
                    // MARK: Favorites
                    NavigationLink {
                        FavoritesMediaList(selectedMedia: $selectedMedia)
                    } label: {
                        ListRowLabel(list: PredicateMediaList.favorites)
                    }
                    
                    // MARK: Watchlist
                    NavigationLink {
                        WatchlistMediaList(selectedMedia: $selectedMedia)
                    } label: {
                        ListRowLabel(list: PredicateMediaList.watchlist)
                    }
                    
                    // MARK: Problems
                    NavigationLink {
                        ProblemsMediaList(selectedMedia: $selectedMedia)
                    } label: {
                        ListRowLabel(list: PredicateMediaList.problems)
                    }
                    
                    // MARK: New Seasons
                    NavigationLink {
                        NewSeasonsMediaList(selectedMedia: $selectedMedia)
                    } label: {
                        ListRowLabel(list: PredicateMediaList.newSeasons)
                    }
                }
                .disabled(editMode?.wrappedValue.isEditing ?? false)
                
                // MARK: - Dynamic Lists
                if !dynamicLists.isEmpty {
                    Section(Strings.Lists.dynamicListsHeader) {
                        ForEach(dynamicLists) { list in
                            // NavigationLink for the lists
                            NavigationLink {
                                DynamicMediaListView(list: list, selectedMedia: $selectedMedia)
                                    .environment(\.editMode, self.editMode)
                            } label: {
                                ListRowLabel(list: list)
                                    .foregroundColor(.primary)
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
                                UserMediaListView(list: list, selectedMedia: $selectedMedia)
                                    .environment(\.editMode, self.editMode)
                            } label: {
                                ListRowLabel(list: list)
                                    .foregroundColor(.primary)
                            }
                        }
                        // List delete
                        .onDelete(perform: deleteUserList(indexSet:))
                    }
                }
            }
            .toolbar(content: toolbar)
            .navigationTitle(Strings.TabView.listsLabel)
            // FUTURE: Disable when no longer bugging around
            .navigationBarTitleDisplayMode(.inline)
        } content: {
            // MARK: List contents showing the medias in the list
            // content is provided by the `NavigationLink`s in the sidebar view
            Text(Strings.Lists.rootPlaceholderText)
        } detail: {
            NavigationStack {
                // MARK: MediaDetail
                if let selectedMedia {
                    MediaDetail()
                        .environmentObject(selectedMedia)
                } else {
                    Text(Strings.Lists.detailPlaceholderText)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    private func deleteDynamicList(indexSet: IndexSet) {
        indexSet.forEach { index in
            self.managedObjectContext.delete(dynamicLists[index])
        }
        PersistenceController.saveContext(managedObjectContext)
    }
    
    private func deleteUserList(indexSet: IndexSet) {
        indexSet.forEach { index in
            self.managedObjectContext.delete(userLists[index])
        }
        PersistenceController.saveContext(managedObjectContext)
    }
    
    @ToolbarContentBuilder private func toolbar() -> some ToolbarContent {
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
            guard let textField = alert.textFields?.first else {
                return
            }
            guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else {
                return
            }
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

struct UserListsViews_Previews: PreviewProvider {
    static var previews: some View {
        MediaListsRootView()
            .environment(\.managedObjectContext, PersistenceController.previewContext)
    }
}
