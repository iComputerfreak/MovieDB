//
//  ExtendedInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ExtendedInfo: View {
    @EnvironmentObject private var mediaObject: Media
    
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            Section(
                header: HStack {
                    Image(systemName: "ellipsis.circle")
                    Text(Strings.Detail.extendedInfoSectionHeader)
                }
            ) {
                // MARK: Tagline
                if let tagline = mediaObject.tagline, !tagline.isEmpty {
                    Text(tagline)
                        .headline(Strings.Detail.taglineHeadline)
                }
                // Movie exclusive data
                if let movie = mediaObject as? Movie {
                    // MARK: Budget
                    if movie.budget > 0 {
                        Text(movie.budget.formatted(.currency(code: "USD")))
                            .headline(Strings.Detail.budgetHeadline)
                    }
                    // MARK: Revenue
                    if movie.revenue > 0 {
                        Text(movie.revenue.formatted(.currency(code: "USD")))
                            .headline(Strings.Detail.revenueHeadline)
                    }
                }
                // MARK: TMDB ID
                let tmdbID = mediaObject.tmdbID.description
                if let url = URL(string: "https://www.themoviedb.org/\(mediaObject.type.rawValue)/\(tmdbID)") {
                    Link("\(tmdbID)", destination: url)
                        .headline(Strings.Detail.tmdbIDHeadline)
                }
                // MARK: IMDB ID
                if
                    let movie = mediaObject as? Movie,
                    let imdbID = movie.imdbID,
                    let url = URL(string: "https://www.imdb.com/title/\(imdbID)")
                {
                    Link(imdbID, destination: url)
                        .headline(Strings.Detail.imdbIDHeadline)
                }
                // MARK: Homepage
                if
                    let address = mediaObject.homepageURL,
                    !address.isEmpty,
                    let homepageURL = URL(string: address)
                {
                    Link(address, destination: homepageURL)
                        .headline(Strings.Detail.homepageHeadline)
                }
                // MARK: Production Companies
                if !mediaObject.productionCompanies.isEmpty {
                    Text(
                        mediaObject.productionCompanies
                            .map(\.name)
                            .sorted()
                            .formatted()
                    )
                    .headline(Strings.Detail.productionCompaniesHeadline)
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
                        .headline(Strings.Detail.networksHeadline)
                    }
                    // MARK: Created By
                    if !show.createdBy.isEmpty {
                        // Sort by last name
                        Text(
                            show.createdBy
                                .sorted(using: LastNameComparator(order: .forward))
                                .formatted()
                        )
                        .headline(Strings.Detail.createdByHeadline)
                    }
                }
                let format: FloatingPointFormatStyle<Float> = .number.precision(.fractionLength(2))
                // MARK: Popularity
                Text(mediaObject.popularity.formatted(format))
                    .headline(Strings.Detail.popularityHeadline)
                // MARK: Score
                // The localized string only shows as many fraction digits as needed, so we can round to at most 2 fraction digits here
                let avg = (Double(mediaObject.voteAverage) * 100).rounded() / 100
                let max: Double = 10
                let count = mediaObject.voteCount
                Text(Strings.Detail.scoringValueLabel(avg, max, count))
                    .headline(Strings.Detail.scoringHeadline)
            }
        }
    }
}

struct ExtendedInfo_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ExtendedInfo()
        }
        .environmentObject(PlaceholderData.movie as Media)
        List {
            ExtendedInfo()
        }
        .environmentObject(PlaceholderData.show as Media)
    }
}
