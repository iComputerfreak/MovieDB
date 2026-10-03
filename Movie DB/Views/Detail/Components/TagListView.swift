// Copyright © 2019 Jonas Frey. All rights reserved.

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
        @State private var isAddingTag = false
        @State private var isShowingDuplicateAlert = false
        @State private var newTagName = ""
        
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
            .navigationBarItems(trailing: Button {
                newTagName = ""
                isAddingTag = true
            } label: {
                Image(systemName: "plus")
            })
            .alert(Strings.Detail.Alert.newTagTitle, isPresented: $isAddingTag) {
                TextField(Strings.Detail.Alert.newTagTitle, text: $newTagName)
                Button(Strings.Generic.alertButtonCancel, role: .cancel) {}
                Button(Strings.Detail.Alert.newTagButtonAdd, action: addTag)
                    .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
            } message: {
                Text(Strings.Detail.Alert.newTagMessage)
            }
            .messageAlert(
                title: Strings.Detail.Alert.tagAlreadyExistsTitle,
                message: Strings.Detail.Alert.tagAlreadyExistsMessage,
                isPresented: $isShowingDuplicateAlert
            )
        }
        
        func addTag() {
            let name = newTagName.trimmingCharacters(in: .whitespaces)
            guard !allTags.contains(where: { $0.name == name }) else {
                Task { @MainActor in
                    // Let the text-entry alert dismiss before presenting the duplicate-name alert.
                    await Task.yield()
                    isShowingDuplicateAlert = true
                }
                return
            }
            _ = Tag(name: name, context: managedObjectContext)
        }
    }
}

#Preview {
    TagListView(.constant([]))
}
