// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

private struct ThumbnailStyleModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(colorScheme == .dark ? 0.08 : 0.45), lineWidth: 1)
            }
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.12), radius: 5, y: 3)
    }
}

extension View {
    /// Applies the shared non-legacy thumbnail chrome used throughout the detail views.
    /// - Parameter cornerRadius: The thumbnail corner radius.
    func thumbnailStyle(cornerRadius: CGFloat = 14) -> some View {
        modifier(ThumbnailStyleModifier(cornerRadius: cornerRadius))
    }
}

extension Image {
    /// Applies the shared non-legacy thumbnail treatment with the standard image sizing behavior.
    /// - Parameters:
    ///   - size: The rendered thumbnail size.
    ///   - cornerRadius: The thumbnail corner radius.
    func thumbnailStyle(size: CGSize = JFLiterals.thumbnailSize, cornerRadius: CGFloat = 14) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .thumbnailStyle(cornerRadius: cornerRadius)
    }
}
