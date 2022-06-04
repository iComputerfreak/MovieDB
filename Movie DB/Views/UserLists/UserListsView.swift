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
    static let defaultListsNames: [(icon: String, name: String)] = [
        ("star.fill", "Favorites"),
        ("checklist", "Watchlist"),
        ("exclamationmark.triangle.fill", "Problems")
    ]
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    @FetchRequest(entity: MediaList.entity(), sortDescriptors: [])
    private var lists: FetchedResults<MediaList>
    
    @State private var addListAlertShowing = false
    
    var defaultLists: [MediaList] {
        lists
            .filter { list in
                Self.defaultListsNames.contains(where: { $0.name == list.name })
            }
            .sorted(using: MediaListComparator(order: .forward))
    }
    
    var userLists: [MediaList] {
        lists
            .filter { list in
                !Self.defaultListsNames.contains(where: { $0.name == list.name })
            }
            .sorted(using: MediaListComparator(order: .forward))
    }
    
    var body: some View {
        NavigationView {
        List {
            Section("Default Lists") {
                ForEach(defaultLists) { list in
                    UserListRow(list: list)
                }
            }
            if !userLists.isEmpty {
                Section("User Lists") {
                    ForEach(userLists) { list in
                        UserListRow(list: list)
                            .deleteDisabled(Self.defaultListsNames.contains(where: { $0.name == list.name }))
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            self.managedObjectContext.delete(userLists[index])
                        }
                        PersistenceController.saveContext(self.managedObjectContext)
                    }
                }
            }
        }
        .onAppear {
            self.populateDefaultLists()
            PersistenceController.saveContext(self.managedObjectContext)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                addListButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .navigationTitle(Strings.TabView.listsLabel)
        }
    }
    
    var addListButton: Button<Image> {
        Button {
            let alert = UIAlertController(
                title: "Add List",
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
                guard !lists.map(\.name).contains(text) else {
                    AlertHandler.showSimpleAlert(title: "List already exists", message: "List already exists")
                    return
                }
                let list = MediaList(context: managedObjectContext)
                list.name = text
            }))
            AlertHandler.presentAlert(alert: alert)
        } label: {
            Image(systemName: "plus")
        }
    }
    
    func populateDefaultLists() {
        for (icon, name) in Self.defaultListsNames {
            createDefaultList(name: name, iconName: icon)
        }
    }
    
    private func createDefaultList(name: String, iconName: String) {
        if !lists.contains(where: { $0.name == name }) {
            // Create List
            let list = MediaList(context: managedObjectContext)
            list.name = name
            list.iconName = iconName
        }
    }
}

struct UserListsViews_Previews: PreviewProvider {
    static var previews: some View {
        UserListsView()
            .environment(\.managedObjectContext, PersistenceController.previewContext)
    }
}

struct MediaListComparator: SortComparator {
    typealias Compared = MediaList
    
    var order: SortOrder
    
    func compare(_ lhs: MediaList, _ rhs: MediaList) -> ComparisonResult {
        let lhsIndex = UserListsView.defaultListsNames
            .firstIndex(where: { $0.name == lhs.name }) ?? UserListsView.defaultListsNames.count
        let rhsIndex = UserListsView.defaultListsNames
            .firstIndex(where: { $0.name == rhs.name }) ?? UserListsView.defaultListsNames.count
        
        if lhsIndex == rhsIndex {
            return lhs.name.compare(rhs.name)
        } else {
            return lhsIndex < rhsIndex ? .orderedAscending : .orderedDescending
        }
    }
}
