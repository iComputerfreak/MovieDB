// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct PosterPlaceholderView: View {
    @Environment(\.colorScheme) private var colorScheme

    let cornerRadius: CGFloat

    init(cornerRadius: CGFloat = 14) {
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        GeometryReader { proxy in
            // The view is designed for JFLiterals.thumbnailSize (80 high with aspect ratio 1.5)
            let scaleFactor = min(10, min(proxy.size.width / (80 / 1.5), proxy.size.height / 80))
            let lineThickness: CGFloat = 5 * scaleFactor
            VStack(spacing: 6 * scaleFactor) {
                Image(systemName: "film")
                    .font(.system(size: 22 * scaleFactor, weight: .semibold))
                    .foregroundStyle(.black60)
                    .padding(.horizontal, scaleFactor)
                    .overlay {
                        Capsule(style: .continuous)
                            .fill(.white60.opacity(0.8))
                            .frame(height: lineThickness)
                            .rotationEffect(.degrees(-38))
                            .shadow(color: .black.opacity(0.28), radius: 2, y: 1)
                    }

                VStack(spacing: 3 * scaleFactor) {
                    placeholderLine(thickness: lineThickness)
                        .frame(width: 34 * scaleFactor)
                    placeholderLine(thickness: lineThickness)
                        .frame(width: 22 * scaleFactor)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white90)
            .thumbnailStyle(cornerRadius: cornerRadius)
        }
    }

    private func placeholderLine(thickness: CGFloat) -> some View {
        Capsule(style: .continuous)
            .fill(.quaternary)
            .frame(height: thickness)
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

#Preview("Full Size") {
    PosterPlaceholderView()
        .padding()
        .background(Color.systemBackground)
}

#Preview("10x") {
    PosterPlaceholderView()
        .frame(width: JFLiterals.thumbnailSize.width * 10, height: JFLiterals.thumbnailSize.height * 10)
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
