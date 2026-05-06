// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct ExtendedInfoSection: View {
    @EnvironmentObject private var mediaObject: Media

    // .fixedSize below helps prevent truncation in the values due to SwiftUI squishing the texts vertically
    // This squish for some reason also creates a gap below the title view that leaves the background image visible.
    var body: some View {
        GroupBoxSection(title: Strings.Detail.extendedInfoSectionHeader) {
            // MARK: Tagline
            if let tagline = mediaObject.tagline, !tagline.isEmpty {
                Text(tagline)
                    .fixedSize(horizontal: false, vertical: true)
                    .headline(Image(systemName: "bubble.left"), Strings.Detail.taglineHeadline)
            }

            if let movie = mediaObject as? Movie {
                // MARK: Budget
                if movie.budget > 0 {
                    Text(movie.budget.formatted(.currency(code: "USD")))
                        .fixedSize(horizontal: false, vertical: true)
                        .headline(Image(systemName: "dollarsign"), Strings.Detail.budgetHeadline)
                }

                // MARK: Revenue
                if movie.revenue > 0 {
                    Text(movie.revenue.formatted(.currency(code: "USD")))
                        .fixedSize(horizontal: false, vertical: true)
                        .headline(Image(systemName: "dollarsign"), Strings.Detail.revenueHeadline)
                }
            }
            // MARK: TMDB ID
            let tmdbID = mediaObject.tmdbID.description
            if let url = URL(string: "https://www.themoviedb.org/\(mediaObject.type.rawValue)/\(tmdbID)") {
                Link("\(tmdbID)", destination: url)
                    .fixedSize(horizontal: false, vertical: true)
                    .headline(Image(systemName: "network"), Strings.Detail.tmdbIDHeadline)
            }
            // MARK: IMDB ID
            if
                let imdbID = mediaObject.imdbID,
                let url = URL(string: "https://www.imdb.com/title/\(imdbID)")
            {
                Link(imdbID, destination: url)
                    .fixedSize(horizontal: false, vertical: true)
                    .headline(Image(systemName: "network"), Strings.Detail.imdbIDHeadline)
            }
            // MARK: Homepage
            if
                let address = mediaObject.homepageURL,
                !address.isEmpty,
                let homepageURL = URL(string: address)
            {
                Link(destination: homepageURL) {
                    Text(address)
                        .lineLimit(1)
                }
                .fixedSize(horizontal: false, vertical: true)
                .headline(Image(systemName: "network"), Strings.Detail.homepageHeadline)
            }
            // MARK: Production Companies
            if !mediaObject.productionCompanies.isEmpty {
                Text(
                    mediaObject.productionCompanies
                        .map(\.name)
                        .sorted()
                        .formatted()
                )
                .fixedSize(horizontal: false, vertical: true)
                .headline(Image(systemName: "building.2"), Strings.Detail.productionCompaniesHeadline)
            }
            // Show exclusive data
            if let show = mediaObject as? Show {
                // MARK: Networks
                if !show.networks.isEmpty {
                    Text(
                        show.networks
                            .map(\.name)
                            .sorted()
                            .formatted()
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .headline(Image(systemName: "bubble.right"), Strings.Detail.networksHeadline)
                }
            }
            // MARK: Popularity
            let format: FloatingPointFormatStyle<Float> = .number.precision(.fractionLength(2))
            Text(mediaObject.popularity.formatted(format))
                .fixedSize(horizontal: false, vertical: true)
                .headline(Image(systemName: "bubble.right"), Strings.Detail.popularityHeadline)
            // MARK: Score
            // The localized string only shows as many fraction digits as needed, so we can round to at most 2 fraction digits here
            let avg = (Double(mediaObject.voteAverage) * 100).rounded() / 100
            let max: Double = 10
            let count = mediaObject.voteCount
            Text(Strings.Detail.scoringValueLabel(avg, max, count))
                .fixedSize(horizontal: false, vertical: true)
                .headline(Image(systemName: "bubble.right"), Strings.Detail.scoringHeadline)
        }
        .multilineTextAlignment(.leading)
    }
}

#Preview {
    VStack {
        ExtendedInfoSection()
        Spacer()
    }
    .padding()
    .previewEnvironment()
}
