// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TrailerCardView: View {
    @ObservedObject var video: Video

    var body: some View {
        if let videoURL = video.videoURL {
            Link(destination: videoURL) {
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
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.quaternary)

            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)
        }
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
