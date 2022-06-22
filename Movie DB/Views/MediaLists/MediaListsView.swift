//
//  UserListsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI
import CoreData

struct UserListsView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    
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
            DefaultMediaList.problems
        ]
        dynamicLists.forEach { lists.append($0) }
        userLists.forEach { lists.append($0) }
        return lists
    }
    
    var body: some View {
        NavigationView {
            List {
                // MARK: Default Lists
                Section("Default Lists") {
                    DefaultListRow(list: DefaultMediaList.favorites) { media in
                        LibraryRow()
                            .environmentObject(media)
                            .swipeActions {
                                Button("Unfavorite") {
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
                                Button("Remove") {
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
                    Section("Dynamic Lists") {
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
                    Section("User Lists") {
                        ForEach(userLists) { list in
                            MediaListRow(list: list) { media in
                                LibraryRow()
                                    .environmentObject(media)
                                // Media delete
                                    .swipeActions {
                                        Button("Delete") {
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
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("New...") {
                        Button("Dynamic List") {
                            let alert = buildAlert("New Dynamic List") { name in
                                let list = DynamicMediaList(context: managedObjectContext)
                                list.name = name
                            }
                            AlertHandler.presentAlert(alert: alert)
                        }
                        Button("Custom List") {
                            let alert = buildAlert("New Custom List") { name in
                                let list = UserMediaList(context: managedObjectContext)
                                list.name = name
                            }
                            AlertHandler.presentAlert(alert: alert)
                        }
                    }
                }
            }
            .navigationTitle(Strings.TabView.listsLabel)
        }
    }
    
    func buildAlert(_ title: String, onSubmit: @escaping (String) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: "Enter the name for the list:",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.autocapitalizationType = .words
        }
        alert.addAction(.cancelAction())
        alert.addAction(.init(title: "Add", style: .default, handler: { _ in
            guard let textField = alert.textFields?.first else {
                return
            }
            guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else {
                return
            }
            guard !allLists.map(\.name).contains(text) else {
                AlertHandler.showSimpleAlert(title: "List already exists", message: "List already exists")
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
