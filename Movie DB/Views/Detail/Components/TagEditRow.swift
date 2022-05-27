//
//  TagEditRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct TagEditRow: View {
    @ObservedObject var tag: Tag
    @Binding var tags: Set<Tag>
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark")
                .hidden(condition: !tags.contains(tag))
            Text(tag.name)
            Spacer()
            Button {
                // Rename
                let alert = UIAlertController(
                    title: Strings.Detail.Alert.renameTagTitle,
                    message: Strings.Detail.Alert.renameTagMessage,
                    preferredStyle: .alert
                )
                alert.addTextField { textField in
                    textField.autocapitalizationType = .words
                    // Fill in the current name
                    textField.text = tag.name
                }
                alert.addAction(.cancelAction())
                alert.addAction(UIAlertAction(
                    title: Strings.Detail.Alert.renameTagButtonRename,
                    style: .default
                ) { _ in
                    guard let textField = alert.textFields?.first else {
                        return
                    }
                    guard let text = textField.text, !text.isEmpty else {
                        return
                    }
                    guard !self.tags.contains(where: { $0.name == text }) else {
                        AlertHandler.showSimpleAlert(
                            title: Strings.Detail.Alert.tagAlreadyExistsTitle,
                            message: Strings.Detail.Alert.tagAlreadyExistsMessage
                        )
                        return
                    }
                    tag.name = text
                })
                AlertHandler.presentAlert(alert: alert)
            } label: {
                Image(systemName: "pencil")
            }
            .foregroundColor(.blue)
        }
    }
}

struct TagEditRow_Previews: PreviewProvider {
    static var previews: some View {
        TagEditRow(tag: Tag(name: "Tag 1", context: PersistenceController.previewContext), tags: .constant([]))
    }
}
