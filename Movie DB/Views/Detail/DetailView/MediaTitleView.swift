// Copyright © 2025 Jonas Frey. All rights reserved.

import Flow
import SwiftUI

@available(iOS 26.0, *)
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
                .font(.largeTitle.scaled(by: 1.2))
                .fontWeight(.heavy)

            HStack {
                StarRatingView(rating: mediaObject.personalRating)
                    .font(.headline)
                if mediaObject.isOnWatchlist {
                    PredicateMediaList.watchlist.icon
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
        .font(.body.scaled(by: 0.9))
    }
}

#Preview("Movie") {
    NavigationStack {
        if #available(iOS 26.0, *) {
        MediaTitleView()
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
            .previewEnvironment()
        } else {
            Text(verbatim: "Only available in iOS 26 and later")
        }
    }
}

#Preview("Show") {
    NavigationStack {
        if #available(iOS 26.0, *) {
        MediaTitleView()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
            .previewEnvironment()
        } else {
            Text(verbatim: "Only available in iOS 26 and later")
        }
    }
}
