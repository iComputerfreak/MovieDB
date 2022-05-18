//
//  TagEditRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct TagEditRow: View {
    let tag: Tag
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
                    title: String(
                        localized: "detail.alert.renameTag.title",
                        comment: "Title of the tag renaming alert"
                    ),
                    message: String(
                        localized: "detail.alert.renameTag.message",
                        comment: "Message of the tag renaming alert"
                    ),
                    preferredStyle: .alert
                )
                alert.addTextField { textField in
                    textField.autocapitalizationType = .words
                    // Fill in the current name
                    textField.text = tag.name
                }
                alert.addAction(.cancelAction())
                alert.addAction(UIAlertAction(
                    title: String(
                        localized: "detail.alert.renameTag.button.rename",
                        comment: "Rename button to confirm renaming a tag"
                    ),
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
                            title: String(
                                localized: "detail.alert.tagAlreadyExists.title",
                                // swiftlint:disable:next line_length
                                comment: "Message of an alert informing the user that the tag they tried to create already exists"
                            ),
                            message: String(
                                localized: "detail.alert.tagAlreadyExists.message",
                                // No way to split up a StaticString into multiple lines
                                // swiftlint:disable:next line_length
                                comment: "Message of an alert informing the user that the tag they tried to create already exists"
                            )
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
