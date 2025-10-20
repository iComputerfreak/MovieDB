// Copyright © 2025 Jonas Frey. All rights reserved.

import Flow
import SwiftUI

struct MediaTitleView: View {
    private enum Constants {
        static let separatorDot: String = "·"
    }

    @EnvironmentObject private var mediaObject: Media

    private let durationFormat: Duration.UnitsFormatStyle = .units(
        allowed: [.hours, .minutes],
        width: .abbreviated,
        zeroValueUnits: .hide
    )

    private var subtitleContents: [String] {
        let movie = mediaObject as? Movie
        let sortedGenreNames = mediaObject.genres
            .map(\.name)
            .sorted(by: { $0.lexicographicallyPrecedes($1) })

        let elements = [
            mediaObject.year.map { $0.formatted(.number.grouping(.never)) },
            movie?.runtime.map { Duration.seconds($0 * 60).formatted(durationFormat) },
            mediaObject.parentalRating.map { "Ab \($0.label) Jahren" },
        ] + sortedGenreNames

        return elements.compactMap(\.self)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(mediaObject.title)
                .font(.title)
                .fontWeight(.heavy)

            HStack {
                StarRatingView(rating: mediaObject.personalRating)
                if mediaObject.isOnWatchlist {
                    Image(systemName: PredicateMediaList.watchlist.iconName)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.blue)
                }
                if mediaObject.isFavorite {
                    Image(systemName: PredicateMediaList.favorites.iconName)
                        .symbolRenderingMode(.multicolor)
                }
                WatchStateLabel()
            }

            Text(mediaObject.overview ?? "")
                .lineLimit(3)

            Text(subtitleContents.joined(separator: " \(Constants.separatorDot) "))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .foregroundStyle(.secondary)
        }
        .font(.system(size: 14))
    }
}

#Preview("Movie") {
    NavigationStack {
        MediaTitleView()
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
            .previewEnvironment()
    }
}

#Preview("Show") {
    NavigationStack {
        MediaTitleView()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
            .previewEnvironment()
    }
}
