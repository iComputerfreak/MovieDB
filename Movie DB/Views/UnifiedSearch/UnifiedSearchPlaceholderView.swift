//
//  UnifiedSearchPlaceholderView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.26.
//  Copyright © 2026 Jonas Frey. All rights reserved.
//

import SwiftUI

struct UnifiedSearchPlaceholderView: View {
    let title: String
    let description: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: "magnifyingglass",
            description: Text(description)
        )
    }
}

#Preview {
    UnifiedSearchPlaceholderView(
        title: Strings.AddMedia.navBarTitle,
        description: Strings.AddMedia.searchPrompt
    )
    .previewEnvironment()
}
