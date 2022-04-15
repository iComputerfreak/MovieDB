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
    @State private var editingTags: Bool = false
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    init(_ tags: Binding<Set<Tag>>) {
        self._tags = tags
    }
    
    var body: some View {
        Group {
            if editMode?.wrappedValue.isEditing ?? false {
                NavigationLink(destination: EditView(tags: self.$tags), isActive: $editingTags) {
                    self.label
                }
                .onTapGesture {
                    // Activate the navigation link manually
                    // FUTURE: Still neccessary?
                    self.editingTags = true
                }
            } else {
                self.label
            }
        }
    }
    
    private var label: some View {
        if tags.isEmpty {
            return Text("None").italic()
        }
        return Text(tags.map(\.name).sorted().joined(separator: ", "))
    }
    
    private struct EditView: View {
        
        @Environment(\.managedObjectContext) private var managedObjectContext
        
        @FetchRequest(
            entity: Tag.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        ) var allTags: FetchedResults<Tag>
        @Binding var tags: Set<Tag>
        
        // Keep a local copy of the tags, sorted by name, to modify
        private var sortedTags: [Tag] {
            allTags.sorted { (tag1, tag2) -> Bool in
                return tag1.name.lexicographicallyPrecedes(tag2.name)
            }
        }
        
        var body: some View {
            List {
                let footerFormatString = NSLocalizedString("%lld tags total", tableName: "Plurals", comment: "Total number of tags")
                let footerString = String.localizedStringWithFormat(footerFormatString, allTags.count)
                Section(header: Text("Select all tags that apply"), footer: Text(footerString)) {
                    ForEach(self.sortedTags, id: \.id) { tag in
                        Button(action: {
                            if self.tags.contains(tag) {
                                print("Removing Tag \(tag.name)")
                                self.tags.remove(tag)
                            } else {
                                print("Adding Tag \(tag.name)")
                                self.tags.insert(tag)
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                    .hidden(condition: !self.tags.contains(tag))
                                Text(tag.name)
                                Spacer()
                                Button(action: {
                                    // Rename
                                    let alert = UIAlertController(title: NSLocalizedString("Rename Tag"), message: NSLocalizedString("Enter a new name for the tag."), preferredStyle: .alert)
                                    alert.addTextField() { textField in
                                        textField.autocapitalizationType = .words
                                    }
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel"), style: .cancel, handler: { _ in }))
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("Rename"), style: .default, handler: { action in
                                        guard let textField = alert.textFields?.first else {
                                            return
                                        }
                                        guard let text = textField.text, !text.isEmpty else {
                                            return
                                        }
                                        tag.name = text
                                    }))
                                    AlertHandler.presentAlert(alert: alert)
                                }) {
                                    Image(systemName: "pencil")
                                }
                                .foregroundColor(.blue)
                            }
                        }.foregroundColor(.primary)
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            let tag = self.sortedTags[index]
                            print("Removing Tag '\(tag.name)' (\(tag.id)).")
                            self.managedObjectContext.delete(tag)
                            PersistenceController.saveContext(context: self.managedObjectContext)
                        }
                    })
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Tags"))
            .navigationBarItems(trailing: Button(action: {
                let alert = UIAlertController(title: NSLocalizedString("New Tag"), message: NSLocalizedString("Enter a name for the new tag."), preferredStyle: .alert)
                alert.addTextField() { textField in
                    // Change textField properties
                    textField.autocapitalizationType = .words
                }
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel"), style: .cancel) { _ in })
                alert.addAction(UIAlertAction(title: NSLocalizedString("Add"), style: .default) { action in
                    guard let textField = alert.textFields?.first else {
                        return
                    }
                    guard let text = textField.text, !text.isEmpty else {
                        return
                    }
                    _ = Tag(name: text, context: self.managedObjectContext)
                })
                AlertHandler.presentAlert(alert: alert)
            }) {
                Image(systemName: "plus")
            })
        }
    }
}

struct TagListView_Previews: PreviewProvider {
    static var previews: some View {
        TagListView(.constant([]))
    }
}
