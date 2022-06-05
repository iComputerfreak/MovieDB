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
    @FetchRequest(entity: DynamicMediaList.entity(), sortDescriptors: [])
    private var lists: FetchedResults<DynamicMediaList>
            
    var userLists: [DynamicMediaList] {
        lists.sorted(by: \.name)
    }
    
    var body: some View {
        NavigationView {
        List {
            Section("Default Lists") {
                DefaultListRow(list: DefaultMediaList.favorites)
                DefaultListRow(list: DefaultMediaList.watchlist)
                DefaultListRow(list: DefaultMediaList.problems)
            }
            if !userLists.isEmpty {
                Section("User Lists") {
                    ForEach(userLists) { list in
                        UserListRow(list: list)
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
                let list = DynamicMediaList(context: managedObjectContext)
                list.name = text
            }))
            AlertHandler.presentAlert(alert: alert)
        } label: {
            Image(systemName: "plus")
        }
    }
}

struct UserListsViews_Previews: PreviewProvider {
    static var previews: some View {
        UserListsView()
            .environment(\.managedObjectContext, PersistenceController.previewContext)
    }
}
