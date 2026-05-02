// Copyright © 2025 Jonas Frey. All rights reserved.

import Flow
import SwiftUI

@available(iOS 26.0, *)
struct MediaTitleView: View {
    private enum Constants {
        static let separatorDot: String = "·"
    }

    @EnvironmentObject private var mediaObject: Media

    private let showsUserSpecificFields: Bool

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
            mediaObject.parentalRating.map(formattedParentalRatingLabel),
        ] + sortedGenreNames

        return elements.compactMap(\.self)
    }

    private var overview: String? {
        guard let overview = mediaObject.overview, !overview.isEmpty else { return nil }
        return overview
    }

    private func formattedParentalRatingLabel(_ rating: ParentalRating) -> String {
        let label = rating.label.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            rating.countryCode.uppercased() == "DE",
            !label.isEmpty,
            label.unicodeScalars.allSatisfy(CharacterSet.decimalDigits.contains)
        else {
            return label
        }

        return Strings.Detail.parentalRatingAgeLabel(label)
    }

    init(showsUserSpecificFields: Bool = true) {
        self.showsUserSpecificFields = showsUserSpecificFields
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(mediaObject.title)
                .font(.largeTitle.scaled(by: 1.2))
                .fontWeight(.heavy)

            if showsUserSpecificFields {
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

                    // TODO: Remove here and use in UserData section instead
                    WatchStateLabel()
                }
            }

            if let overview {
                TruncatingTextSheet(
                    overview,
                    sheetTitle: Strings.Detail.descriptionHeadline
                )
            }

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
