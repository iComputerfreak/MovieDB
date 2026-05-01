// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct PosterPlaceholderView: View {
    @Environment(\.colorScheme) private var colorScheme

    let cornerRadius: CGFloat

    init(cornerRadius: CGFloat = 14) {
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "film")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.black70)
                .padding(.horizontal, 4)
                .overlay {
                    Capsule(style: .continuous)
                        .fill(.black70.opacity(0.8))
                        .frame(height: 5)
                        .rotationEffect(.degrees(-38))
                        .shadow(color: .black.opacity(0.28), radius: 2, y: 1)
                }

            VStack(spacing: 6) {
                placeholderLine
                    .frame(width: 34)
                placeholderLine
                    .frame(width: 22)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white90)
        .thumbnailStyle(cornerRadius: cornerRadius)
    }

    private var placeholderLine: some View {
        Capsule(style: .continuous)
            .fill(.quaternary)
            .frame(height: 5)
    }
}

extension PosterPlaceholderView {
    static func thumbnail(size: CGSize = JFLiterals.thumbnailSize, cornerRadius: CGFloat = 14) -> some View {
        PosterPlaceholderView(cornerRadius: cornerRadius)
            .frame(width: size.width, height: size.height)
    }

    static func legacyThumbnail(multiplier: CGFloat = 1.0) -> some View {
        PosterPlaceholderView(cornerRadius: 0)
            .frame(
                width: JFLiterals.thumbnailSize.width * multiplier,
                height: JFLiterals.thumbnailSize.height * multiplier,
                alignment: .center
            )
    }
}

#Preview("Scaled up") {
    PosterPlaceholderView()
        .frame(width: JFLiterals.thumbnailSize.width, height: JFLiterals.thumbnailSize.height)
        .padding()
        .background(Color.systemBackground)
        .scaleEffect(4)
}

#Preview("Library Size") {
    PosterPlaceholderView()
        .frame(width: JFLiterals.thumbnailSize.width, height: JFLiterals.thumbnailSize.height)
        .padding()
        .background(Color.systemBackground)
}

#Preview("Detail Size") {
    PosterPlaceholderView(cornerRadius: 18)
        .frame(
            width: JFLiterals.thumbnailSize.width * JFLiterals.detailThumbnailMultiplier,
            height: JFLiterals.thumbnailSize.height * JFLiterals.detailThumbnailMultiplier
        )
        .padding()
        .background(Color.systemBackground)
}
