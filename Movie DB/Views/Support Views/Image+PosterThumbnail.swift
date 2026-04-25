//
//  Image+PosterThumbnail.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.04.26.
//  Copyright © 2026 Jonas Frey. All rights reserved.
//

import SwiftUI

private struct PosterThumbnailView: View {
    @Environment(\.colorScheme) private var colorScheme

    let image: Image
    let size: CGSize
    let cornerRadius: CGFloat

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(colorScheme == .dark ? 0.08 : 0.45), lineWidth: 1)
            }
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.12), radius: 8, y: 4)
    }
}

extension Image {
    /// Applies the shared poster-style thumbnail treatment used in the non-legacy detail views.
    /// - Parameters:
    ///   - size: The rendered thumbnail size.
    ///   - cornerRadius: The thumbnail corner radius.
    func posterThumbnail(size: CGSize = JFLiterals.thumbnailSize, cornerRadius: CGFloat = 14) -> some View {
        PosterThumbnailView(image: self, size: size, cornerRadius: cornerRadius)
    }
}
