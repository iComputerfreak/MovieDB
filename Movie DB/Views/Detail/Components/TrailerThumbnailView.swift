// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI
import UIKit
import os.log

struct TrailerThumbnailView: View {
    @ObservedObject var video: Video

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.quaternary)
            }
        }
        // We explicitly use .onAppear instead of .task here to continue the download even if the view (temporarily) disappears.
        .onAppear {
            Task {
                await loadThumbnail()
            }
        }
    }

    @MainActor
    private func loadThumbnail() async {
        image = nil

        let videoName = video.name
        let videoKey = video.key

        for thumbnailURL in video.trailerThumbnailURLs {
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

                image = loadedImage
                return
            } catch {
                let thumbnailURLString = thumbnailURL.absoluteString
                let errorDescription = error.localizedDescription

                // swiftlint:disable:next line_length
                Logger.detail.warning("Trailer thumbnail load failed for \(videoName, privacy: .public): \(thumbnailURLString, privacy: .public) error: \(errorDescription, privacy: .public)")
            }
        }

        if !video.trailerThumbnailURLs.isEmpty {
            // swiftlint:disable:next line_length
            Logger.detail.error("All trailer thumbnail candidates failed for \(videoName, privacy: .public) with key \(videoKey, privacy: .public)")
        }
    }
}

#Preview {
    let video = PlaceholderData.preview.staticMovie.videos
        .first(where: { $0.videoURL != nil })!

    TrailerThumbnailView(video: video)
        .frame(width: 220, height: 124)
        .previewEnvironment()
}
