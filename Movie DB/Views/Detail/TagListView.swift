//
//  TagListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct TagListView: View {
    
    @Binding var tags: [Int]
    @Environment(\.editMode) private var editMode
    @State private var editingTags: Bool = false
    
    init(_ tags: Binding<[Int]>) {
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
        return Text(tags.map({ TagLibrary.shared.name(for: $0) ?? "<Unknown Tag>" }).joined(separator: ", "))
    }
    
    private struct EditView: View {
        @ObservedObject var tagLibrary = TagLibrary.shared
        @Binding var tags: [Int]
        
        var body: some View {
            List {
                ForEach(TagLibrary.shared.tags) { tag in
                    Button(action: {
                        if self.tags.contains(tag.id) {
                            self.tags.removeAll(where: { $0 == tag.id })
                        } else {
                            self.tags.append(tag.id)
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                                .hidden(condition: !self.tags.contains(tag.id))
                            Text(tag.name)
                            Spacer()
                            Button(action: {
                                // Rename
                                let alert = UIAlertController(title: "Rename Tag", message: "Enter a new name for the tag.", preferredStyle: .alert)
                                alert.addTextField() { textField in
                                    textField.autocapitalizationType = .words
                                }
                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
                                alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { action in
                                    guard let textField = alert.textFields?.first else {
                                        return
                                    }
                                    guard let text = textField.text, !text.isEmpty else {
                                        return
                                    }
                                    TagLibrary.shared.rename(id: tag.id, newName: text)
                                }))
                                AlertHandler.showAlert(alert: alert)
                            }) {
                                Image(systemName: "pencil")
                            }
                            .foregroundColor(.blue)
                        }
                    }.foregroundColor(.primary)
                }
                .onDelete(perform: TagLibrary.shared.remove(atOffsets:))
            }
            .navigationBarTitle(Text("Tags"))
            .navigationBarItems(trailing: Button(action: {
                let alert = UIAlertController(title: "New Tag", message: "Enter a name for the new tag.", preferredStyle: .alert)
                alert.addTextField() { textField in
                    // Change textField appearance
                    textField.autocapitalizationType = .words
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
                alert.addAction(UIAlertAction(title: "Add", style: .default) { action in
                    guard let textField = alert.textFields?.first else {
                        return
                    }
                    guard let text = textField.text, !text.isEmpty else {
                        return
                    }
                    TagLibrary.shared.create(name: text)
                })
                AlertHandler.showAlert(alert: alert)
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
