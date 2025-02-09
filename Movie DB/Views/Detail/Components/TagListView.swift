//
//  TagListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import CoreData
import os.log
import SwiftUI

struct TagListView: View {
    enum NavigationDestination {
        case editing
    }
    
    @Binding var tags: Set<Tag>
    @Environment(\.isEditing) private var isEditing
    
    init(_ tags: Binding<Set<Tag>>) {
        _tags = tags
    }
    
    var body: some View {
        if isEditing {
            // !!!: For some reason, using NavigationLink(destination:label:) here, causes an infinite rendering loop,
            // !!!: so we use a navigationDestination with a private enum as a workaround.
            NavigationLink(value: NavigationDestination.editing) {
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
        
        @FetchRequest(sortDescriptors: [SortDescriptor(\Tag.name, order: .forward)])
        var allTags: FetchedResults<Tag>
        @Binding var tags: Set<Tag>
        
        init(tags: Binding<Set<Tag>>) {
            self._tags = tags
        }
        
        var body: some View {
            List {
                Section(
                    header: Text(Strings.Detail.tagsHeadline),
                    footer: Text(Strings.Detail.tagsFooter(allTags.count))
                ) {
                    ForEach(allTags) { tag in
                        if !tag.isFault {
                            Button {
                                if self.tags.contains(tag) {
                                    Logger.general.info("Removing Tag \(tag.name, privacy: .public)")
                                    self.tags.remove(tag)
                                } else {
                                    Logger.general.info("Adding Tag \(tag.name, privacy: .public)")
                                    self.tags.insert(tag)
                                }
                            } label: {
                                TagEditRow(tag: tag, tags: $tags)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            let tag = self.allTags[index]
                            Logger.general.info(
                                // swiftlint:disable:next line_length
                                "Removing Tag '\(tag.name, privacy: .public)' (\(tag.id?.uuidString ?? "nil", privacy: .public))"
                            )
                            // If we are making UI changes, we better be on the main thread/context
                            assert(Thread.current.isMainThread)
                            assert(managedObjectContext == PersistenceController.viewContext)
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
                guard let textField = alert.textFields?.first else { return }
                guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return }
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

#Preview {
    TagListView(.constant([]))
}
