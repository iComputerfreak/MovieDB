// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TrailerCardView: View {
    @ObservedObject var video: Video
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                thumbnail

                VStack(alignment: .leading, spacing: 6) {
                    Text(video.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 6) {
                        CapsuleLabelView(text: video.site)

                        if let resolutionLabel {
                            CapsuleLabelView(text: resolutionLabel)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            }
            .frame(width: 220, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.calloutBackground)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var thumbnail: some View {
        ZStack {
            AsyncImage(url: video.trailerThumbnailURL) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    fallbackThumbnail
                case .empty:
                    fallbackThumbnail
                @unknown default:
                    fallbackThumbnail
                }
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.45)],
                startPoint: .top,
                endPoint: .bottom
            )

            Image(systemName: "play.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .padding(14)
                .background(.black.opacity(0.55), in: Circle())
        }
        .frame(width: 220, height: 124)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var fallbackThumbnail: some View {
        Rectangle()
            .fill(.quaternary)
    }

    private var resolutionLabel: String? {
        guard video.resolution > 0 else { return nil }

        switch video.resolution {
        case 2160...:
            return "4K"
        case 1440..<2160:
            return "1440p"
        default:
            return "\(video.resolution)p"
        }
    }
}

#Preview("Thumbnail") {
    let videos = PlaceholderData.preview.staticShow.videos
    ScrollView {
        ForEach(Array(videos)) { video in
            TrailerCardView(video: video) {}
                .frame(maxWidth: .infinity)
        }
    }
    .previewEnvironment()
}

#Preview("Fallback") {
    let video = PlaceholderData.preview.staticMovie.videos
        .first(where: { $0.videoURL != nil })
        .map { video in
            var videoWithoutThumbnail = video
            videoWithoutThumbnail.key = "asdf"
            return videoWithoutThumbnail
        }!
    TrailerCardView(video: video) {}
        .previewEnvironment()
}
