//
//  TagListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import CoreData

struct TagListView: View {
    @Binding var tags: Set<Tag>
    @Environment(\.editMode) private var editMode
    @State private var editingTags = false
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    // swiftlint:disable:next type_contents_order
    init(_ tags: Binding<Set<Tag>>) {
        self._tags = tags
    }
    
    var body: some View {
        if editMode?.wrappedValue.isEditing ?? false {
            NavigationLink(destination: EditView(tags: self.$tags), isActive: $editingTags) {
                self.label
            }
            .onTapGesture {
                // Activate the navigation link manually, because we are in edit mode and cannot activate NavLinks
                // FUTURE: Still neccessary?
                self.editingTags = true
            }
        } else {
            self.label
        }
    }
    
    private var label: some View {
        if tags.isEmpty {
            return Text("None").italic()
        }
        return Text(tags.map(\.name).sorted().joined(separator: ", "))
    }
    
    // TODO: Move into its own file
    private struct EditView: View {
        @Environment(\.managedObjectContext) private var managedObjectContext
        
        @FetchRequest(
            entity: Tag.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        ) var allTags: FetchedResults<Tag>
        @Binding var tags: Set<Tag>
        
        // Keep a local copy of the tags, sorted by name, to modify
        private var sortedTags: [Tag] { allTags.sorted(by: \.name) }
        
        var body: some View {
            List {
                let footerFormatString = NSLocalizedString(
                    "%lld tags total",
                    tableName: "Plurals",
                    comment: "Total number of tags"
                )
                let footerString = String.localizedStringWithFormat(footerFormatString, allTags.count)
                Section(header: Text("Select all tags that apply"), footer: Text(footerString)) {
                    ForEach(self.sortedTags.sorted(by: \.name), id: \.id) { tag in
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
                            let tag = self.sortedTags[index]
                            print("Removing Tag '\(tag.name)' (\(tag.id)).")
                            self.managedObjectContext.delete(tag)
                            // Save asynchronous
                            Task {
                                await PersistenceController.saveContext(self.managedObjectContext)
                            }
                        }
                    })
                }
            }
            .listStyle(.grouped)
            .navigationBarTitle(Text("Tags"))
            .navigationBarItems(trailing: Button(action: addTag) {
                Image(systemName: "plus")
            })
        }
        
        func addTag() {
            let alert = UIAlertController(
                title: NSLocalizedString("New Tag", comment: "Title of an alert for adding a new tag"),
                message: NSLocalizedString(
                    "Enter a name for the new tag.",
                    comment: "Text of an alert for adding a new tag"
                ),
                preferredStyle: .alert
            )
            alert.addTextField { textField in
                // Change textField properties
                textField.autocapitalizationType = .words
            }
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Button of an alert to cancel adding a new tag"),
                style: .cancel,
                handler: { _ in }
            ))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Add", comment: "Button of an alert to confirm adding a new tag"),
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
                        title: "Error adding Tag",
                        message: "There is already a tag with that name."
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
