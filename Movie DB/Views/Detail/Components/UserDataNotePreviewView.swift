// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct UserDataNotePreviewView: View {
    let notePreview: String
    let isEmpty: Bool
    let isEditing: Bool

    var body: some View {
        Text(notePreview)
            .lineLimit(isEditing ? 3 : 5)
            .multilineTextAlignment(.leading)
            .foregroundStyle(isEmpty ? .secondary : .primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.quaternary.opacity(0.45))
            )
    }
}
