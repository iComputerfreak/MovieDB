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
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)

            Text(description)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    UnifiedSearchPlaceholderView(
        title: Strings.AddMedia.navBarTitle,
        description: Strings.AddMedia.searchPrompt
    )
    .previewEnvironment()
}
