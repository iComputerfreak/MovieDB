// Copyright © 2022 Jonas Frey. All rights reserved.

import SwiftUI

struct TagEditRow: View {
    @ObservedObject var tag: Tag
    @Binding var tags: Set<Tag>
    @State private var isRenaming = false
    @State private var isShowingDuplicateAlert = false
    @State private var name = ""
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark")
                .hidden(condition: !tags.contains(tag))
            Text(tag.name)
            Spacer()
            Button {
                name = tag.name
                isRenaming = true
            } label: {
                Image(systemName: "pencil")
            }
            .foregroundColor(.accentColor)
        }
        .alert(Strings.Detail.Alert.renameTagTitle, isPresented: $isRenaming) {
            TextField(Strings.Detail.Alert.renameTagTitle, text: $name)
            Button(Strings.Generic.alertButtonCancel, role: .cancel) {}
            Button(Strings.Detail.Alert.renameTagButtonRename, action: renameTag)
                .disabled(name.isEmpty)
        } message: {
            Text(Strings.Detail.Alert.renameTagMessage)
        }
        .messageAlert(
            title: Strings.Detail.Alert.tagAlreadyExistsTitle,
            message: Strings.Detail.Alert.tagAlreadyExistsMessage,
            isPresented: $isShowingDuplicateAlert
        )
    }

    /// Renames the tag when its proposed name is unique.
    private func renameTag() {
        guard !tags.contains(where: { $0.name == name }) else {
            Task { @MainActor in
                // Let the text-entry alert dismiss before presenting the duplicate-name alert.
                await Task.yield()
                isShowingDuplicateAlert = true
            }
            return
        }
        tag.name = name
    }
}

#Preview {
    TagEditRow(tag: Tag(name: "Tag 1", context: PersistenceController.xcodePreviewContext), tags: .constant([]))
}
