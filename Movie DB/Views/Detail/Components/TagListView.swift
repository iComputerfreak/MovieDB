//
//  TagListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import CoreData
import SwiftUI

struct TagListView: View {
    @Binding var tags: Set<Tag>
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.isEditing) private var isEditing
    
    // swiftlint:disable:next type_contents_order
    init(_ tags: Binding<Set<Tag>>) {
        _tags = tags
    }
    
    var body: some View {
        if isEditing {
            NavigationLink {
                EditView(tags: $tags)
                    .environment(\.managedObjectContext, managedObjectContext)
                    .environment(\.isEditing, isEditing)
            } label: {
                TagListViewLabel(tags: tags)
                    .headline(Strings.Detail.tagsHeadline)
            }
        } else {
            TagListViewLabel(tags: tags)
                .headline(Strings.Detail.tagsHeadline)
        }
    }
    
    struct TagListViewLabel: View {
        let tags: Set<Tag>
        
        var body: some View {
            if tags.isEmpty {
                Text(Strings.Detail.noTagsLabel)
                    .italic()
            } else {
                Text(
                    tags
                        .map(\.name)
                        .sorted()
                        .joined(separator: ", ")
                )
            }
        }
    }
    
    struct EditView: View {
        @Environment(\.managedObjectContext) private var managedObjectContext
        
        // FIXME: This @FetchRequest somehow break the whole app when using a NavigationLink in Detail while isEditing is true
        // - isEditing == true (otherwise EditView is not created)
        // - EditView is destination of a NavigationLink
        // - other NavigationLink is triggered
        @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)])
        private var allTags: FetchedResults<Tag>
        
        @Binding var tags: Set<Tag>
        
        var body: some View {
            List {
                Section(
                    header: Text(Strings.Detail.tagsHeadline),
                    footer: Text(Strings.Detail.tagsFooter(allTags.count))
                ) {
                    ForEach(allTags, id: \.id) { tag in
                        Button {
                            if self.tags.contains(tag) {
                                print("Removing Tag \(tag.name)")
                                self.tags.remove(tag)
                            } else {
                                print("Adding Tag \(tag.name)")
                                self.tags.insert(tag)
                            }
                        } label: {
                            TagEditRow(tag: tag, tags: $tags)
                        }
                        .foregroundColor(.primary)
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            let tag = self.allTags[index]
                            print("Removing Tag '\(tag.name)' (\(tag.id)).")
                            self.managedObjectContext.delete(tag)
                        }
                        // Save the deletion of the tags asynchronously
                        Task {
                            await PersistenceController.saveContext(self.managedObjectContext)
                        }
                    })
                }
            }
            .listStyle(.grouped)
            .navigationTitle(Strings.Detail.tagsNavBarTitle)
            .navigationBarItems(trailing: Button(action: addTag) {
                Image(systemName: "plus")
            })
        }
        
        func addTag() {
            let alert = UIAlertController(
                title: Strings.Detail.Alert.newTagTitle,
                message: Strings.Detail.Alert.newTagMessage,
                preferredStyle: .alert
            )
            alert.addTextField { textField in
                // Change textField properties
                textField.autocapitalizationType = .words
            }
            alert.addAction(.cancelAction())
            alert.addAction(UIAlertAction(
                title: Strings.Detail.Alert.newTagButtonAdd,
                style: .default
            ) { _ in
                guard let textField = alert.textFields?.first else {
                    return
                }
                guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else {
                    return
                }
                guard !self.tags.contains(where: { $0.name == text }) else {
                    AlertHandler.showSimpleAlert(
                        title: Strings.Detail.Alert.tagAlreadyExistsTitle,
                        message: Strings.Detail.Alert.tagAlreadyExistsMessage
                    )
                    return
                }
                _ = Tag(name: text, context: self.managedObjectContext)
            })
            AlertHandler.presentAlert(alert: alert)
        }
    }
}

struct TagListView_Previews: PreviewProvider {
    static var previews: some View {
        TagListView(.constant([]))
    }
}
