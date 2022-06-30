//
//  UserListsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import SwiftUI

struct UserListsView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.editMode) private var editMode
    
    @FetchRequest(
        entity: DynamicMediaList.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) private var dynamicLists: FetchedResults<DynamicMediaList>
    
    @FetchRequest(
        entity: UserMediaList.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    ) private var userLists: FetchedResults<UserMediaList>
    
    var allLists: [MediaListProtocol] {
        var lists: [MediaListProtocol] = [
            DefaultMediaList.favorites,
            DefaultMediaList.watchlist,
            DefaultMediaList.problems,
        ]
        dynamicLists.forEach { lists.append($0) }
        userLists.forEach { lists.append($0) }
        return lists
    }
    
    // TODO: View is too big, split up
    var body: some View {
        NavigationView {
            List {
                // MARK: Default Lists
                Section(Strings.Lists.defaultListsHeader) {
                    DefaultListRow(list: DefaultMediaList.favorites) { media in
                        LibraryRow()
                            .environmentObject(media)
                            .swipeActions {
                                Button(Strings.Detail.menuButtonUnfavorite) {
                                    assert(media.isFavorite)
                                    media.isFavorite = false
                                }
                            }
                    }
                    DefaultListRow(list: DefaultMediaList.watchlist) { media in
                        LibraryRow()
                            .environmentObject(media)
                            // Remove from watchlist
                            .swipeActions {
                                Button(Strings.Lists.removeMediaLabel) {
                                    media.isOnWatchlist = false
                                }
                            }
                    }
                    // For the problems list, show the ProblemsView instead of the normal list rows
                    DefaultListRow(list: DefaultMediaList.problems) { media in
                        ProblemsLibraryRow()
                            .environmentObject(media)
                    }
                }
                // MARK: Dynamic Lists
                if !dynamicLists.isEmpty {
                    Section(Strings.Lists.dynamicListsHeader) {
                        ForEach(dynamicLists) { list in
                            MediaListRow(list: list) { media in
                                LibraryRow()
                                    .environmentObject(media)
                            }
                        }
                        // List delete
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                self.managedObjectContext.delete(dynamicLists[index])
                            }
                            PersistenceController.saveContext(self.managedObjectContext)
                        }
                    }
                }
                // MARK: User Lists
                if !userLists.isEmpty {
                    Section(Strings.Lists.customListsHeader) {
                        ForEach(userLists) { list in
                            MediaListRow(list: list) { media in
                                LibraryRow()
                                    .environmentObject(media)
                                    // Media delete
                                    .swipeActions {
                                        Button(Strings.Lists.deleteLabel) {
                                            list.medias.remove(media)
                                            PersistenceController.saveContext()
                                        }
                                    }
                            }
                        }
                        // List delete
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                self.managedObjectContext.delete(userLists[index])
                            }
                            PersistenceController.saveContext(self.managedObjectContext)
                        }
                    }
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
                        Button(Strings.Lists.newCustomListLabel) {
                            let alert = buildAlert(Strings.Lists.Alert.newCustomListTitle) { name in
                                let list = UserMediaList(context: managedObjectContext)
                                list.name = name
                                PersistenceController.saveContext(managedObjectContext)
                            }
                            AlertHandler.presentAlert(alert: alert)
                        }
                    }
                }
            }
            .navigationTitle(Strings.TabView.listsLabel)
        }
    }
    
    private func buildAlert(_ title: String, onSubmit: @escaping (String) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: Strings.Lists.Alert.newListMessage,
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.autocapitalizationType = .words
        }
        alert.addAction(.cancelAction())
        alert.addAction(.init(title: Strings.Lists.Alert.newListButtonAdd, style: .default, handler: { _ in
            guard let textField = alert.textFields?.first else {
                return
            }
            guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else {
                return
            }
            // Check on equality, ignoring case
            guard !allLists.map(\.name).map { $0.lowercased() }.contains(text.lowercased()) else {
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
        UserListsView()
            .environment(\.managedObjectContext, PersistenceController.previewContext)
    }
}
