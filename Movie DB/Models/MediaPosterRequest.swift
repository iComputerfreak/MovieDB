// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Immutable values needed to load a media poster without retaining its managed object.
struct MediaPosterRequest: Hashable, Sendable {
    let mediaID: UUID
    let imagePath: String
    let revision: Date?

    /// Loads a downsampled poster from the local cache or TMDB.
    /// - Parameter maxPixelSize: Maximum width or height of the decoded image in pixels.
    /// - Returns: The loaded poster, or `nil` when no valid image is available.
    func load(maxPixelSize: Int) async throws -> NSUIImage? {
        try await TMDBImageService.mediaThumbnails.thumbnail(
            for: mediaID,
            imagePath: imagePath,
            maxPixelSize: maxPixelSize
        )
    }
}

// MARK: - Poster Request
extension Media {
    /// Immutable poster request safe to capture in an asynchronous view task.
    var posterRequest: MediaPosterRequest? {
        guard let id, let imagePath, !imagePath.isEmpty else { return nil }
        return MediaPosterRequest(mediaID: id, imagePath: imagePath, revision: lastUpdated)
    }
}
