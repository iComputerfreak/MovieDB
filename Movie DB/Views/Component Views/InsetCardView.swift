// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct InsetCardView<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content

    private var backgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.92)
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(.quaternary.opacity(0.8), lineWidth: 1)
                    )
            )
    }
}
