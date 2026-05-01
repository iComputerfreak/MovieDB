// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI
import UIKit

struct SeasonCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var season: Season
    @Binding var thumbnail: UIImage??

    private var overview: String? {
        guard let overview = season.overview, !overview.isEmpty else { return nil }
        return overview
    }

    private var metadataBadges: some View {
        HStack(spacing: 6) {
            if let airDate = season.airDate {
                CapsuleLabelView(backgroundColor: .gray95) {
                    Label(airDate.formatted(date: .numeric, time: .omitted), systemImage: "calendar")
                }
            }

            CapsuleLabelView(backgroundColor: .gray95) {
                Label(Strings.Detail.seasonsInfoEpisodeCount(season.episodeCount), systemImage: "play.tv")
            }
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Group {
                if case let .some(.some(thumbnail)) = thumbnail {
                    Image(uiImage: thumbnail)
                        .thumbnailStyle(size: JFLiterals.seasonThumbnailSize)
                } else {
                    PosterPlaceholderView.thumbnail(size: JFLiterals.seasonThumbnailSize)
                }
            }

            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(season.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    metadataBadges

                    if let overview {
                        Rectangle()
                            .fill(.quaternary)
                            .frame(height: 1)
                            .padding(.top, 2)

                        Text(overview)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if overview != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .padding(.top, 4)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.gray90)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(.white.opacity(colorScheme == .dark ? 0.08 : 0.6), lineWidth: 1)
                }
        )
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.18 : 0.06), radius: 10, y: 4)
    }
}

#Preview {
    let show = PlaceholderData.preview.createStaticShow()

    VStack {
        SeasonCardView(
            season: show.seasons.sorted(on: \.seasonNumber, by: <).last!,
            thumbnail: .constant(nil)
        )
        .padding()
        Spacer()
    }
    .previewEnvironment()
}
