// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI
import UIKit
import os.log

struct TrailerThumbnailView: View {
    @ObservedObject var video: Video

    private var imageSource: LoadableImageSource {
        let thumbnailURLs = video.trailerThumbnailURLs
        let videoName = video.name
        let videoKey = video.key

        return .loader(id: video.objectID) {
            await Self.loadThumbnail(
                from: thumbnailURLs,
                videoName: videoName,
                videoKey: videoKey
            )
        }
    }

    var body: some View {
        LoadableImageView(source: imageSource)
    }

    private static func loadThumbnail(
        from thumbnailURLs: [URL],
        videoName: String,
        videoKey: String
    ) async -> UIImage? {
        for thumbnailURL in thumbnailURLs {
            do {
                let (data, response) = try await URLSession.shared.data(from: thumbnailURL)
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let thumbnailURLString = thumbnailURL.absoluteString

                guard statusCode == 200 else {
                    // swiftlint:disable:next line_length
                    Logger.detail.warning("Trailer thumbnail request failed for \(videoName, privacy: .public) with status \(statusCode, privacy: .public): \(thumbnailURLString, privacy: .public)")
                    continue
                }

                guard let loadedImage = UIImage(data: data) else {
                    // swiftlint:disable:next line_length
                    Logger.detail.warning("Trailer thumbnail decode failed for \(videoName, privacy: .public): \(thumbnailURLString, privacy: .public)")
                    continue
                }

                return loadedImage
            } catch {
                let thumbnailURLString = thumbnailURL.absoluteString
                let errorDescription = error.localizedDescription

                // swiftlint:disable:next line_length
                Logger.detail.warning("Trailer thumbnail load failed for \(videoName, privacy: .public): \(thumbnailURLString, privacy: .public) error: \(errorDescription, privacy: .public)")
            }
        }

        if !thumbnailURLs.isEmpty {
            // swiftlint:disable:next line_length
            Logger.detail.warning("All trailer thumbnail candidates failed for \(videoName, privacy: .public) with key \(videoKey, privacy: .public)")
        }

        return nil
    }
}

#Preview {
    let video = PlaceholderData.preview.staticMovie.videos
        .first(where: { $0.videoURL != nil })!

    TrailerThumbnailView(video: video)
        .frame(width: 220, height: 124)
        .previewEnvironment()
}
