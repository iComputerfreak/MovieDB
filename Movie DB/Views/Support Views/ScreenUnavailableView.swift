// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct ScreenUnavailableView: View {
    let title: String
    let systemImage: String
    let description: String?
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        title: String,
        systemImage: String,
        description: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    init(
        title: String,
        systemImage: String,
        error: Error,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        let description = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        self.init(
            title: title,
            systemImage: systemImage,
            description: description.isEmpty ? Strings.Generic.errorText : description,
            actionTitle: actionTitle,
            action: action
        )
    }

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            if let description {
                Text(description)
            }
        } actions: {
            if let actionTitle, let action {
                Button(action: action) {
                    Label(actionTitle, systemImage: "arrow.clockwise")
                        .padding(4)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview("Retry") {
    ScreenUnavailableView(
        title: Strings.Lookup.Alert.errorLoadingTitle,
        systemImage: "exclamationmark.triangle",
        description: Strings.Generic.errorText,
        actionTitle: Strings.Generic.retryLoading,
        action: {}
    )
    .previewEnvironment()
}

#Preview("Empty") {
    ScreenUnavailableView(
        title: Strings.Library.EmptyState.nothingHere,
        systemImage: "tray",
        description: Strings.Library.EmptyState.descriptionNoContent
    )
    .previewEnvironment()
}
