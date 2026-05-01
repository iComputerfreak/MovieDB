// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct UnifiedSearchPlaceholderView: View {
    let title: String
    let description: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: "magnifyingglass")
        } description: {
            Text(description)
        } actions: {
            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    UnifiedSearchPlaceholderView(
        title: Strings.AddMedia.navBarTitle,
        description: Strings.AddMedia.searchPrompt
    )
    .previewEnvironment()
}
