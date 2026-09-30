// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

/// Lazily loads a downsampled media poster for the lifetime of its presenting view.
struct MediaPosterView: View {
    let request: MediaPosterRequest?
    let pointSize: CGSize
    let contentMode: ContentMode
    let alignment: Alignment

    @Environment(\.displayScale) private var displayScale

    /// Creates a lazily loaded media poster.
    /// - Parameters:
    ///   - request: Immutable poster request, or `nil` for a placeholder.
    ///   - pointSize: Largest size at which the poster will be displayed.
    ///   - contentMode: Scaling mode applied to the poster.
    ///   - alignment: Poster alignment inside available space.
    init(
        request: MediaPosterRequest?,
        pointSize: CGSize,
        contentMode: ContentMode = .fill,
        alignment: Alignment = .center
    ) {
        self.request = request
        self.pointSize = pointSize
        self.contentMode = contentMode
        self.alignment = alignment
    }

    var body: some View {
        LoadableImageView(
            source: source,
            contentMode: contentMode,
            alignment: alignment
        )
    }

    private var source: LoadableImageSource {
        guard let request else { return .image(nil) }
        let maxPixelSize = Int(ceil(max(pointSize.width, pointSize.height) * displayScale))
        let loaderID = AnyHashable([AnyHashable(request), AnyHashable(maxPixelSize)])
        return .loader(id: loaderID) {
            try await request.load(maxPixelSize: maxPixelSize)
        }
    }
}

#Preview {
    MediaPosterView(request: nil, pointSize: JFLiterals.thumbnailSize)
        .frame(width: JFLiterals.thumbnailSize.width, height: JFLiterals.thumbnailSize.height)
}
