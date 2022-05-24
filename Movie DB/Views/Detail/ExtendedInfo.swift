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
                if let tagline = mediaObject.tagline, !tagline.isEmpty {
                    Text(tagline)
                        .headline(Strings.Detail.taglineHeadline)
                }
                // Movie exclusive data
                if let movie = mediaObject as? Movie {
                    if movie.budget > 0 {
                        Text(movie.budget.formatted(.currency(code: "USD")))
                            .headline(Strings.Detail.budgetHeadline)
                    }
                    if movie.revenue > 0 {
                        Text(movie.revenue.formatted(.currency(code: "USD")))
                            .headline(Strings.Detail.revenueHeadline)
                    }
                }
                let tmdbID = mediaObject.tmdbID.description
                if let url = URL(string: "https://www.themoviedb.org/\(mediaObject.type.rawValue)/\(tmdbID)") {
                    Link("\(tmdbID)", destination: url)
                        .headline(Strings.Detail.tmdbIDHeadline)
                }
                if
                    let movie = mediaObject as? Movie,
                    let imdbID = movie.imdbID,
                    let url = URL(string: "https://www.imdb.com/title/\(imdbID)")
                {
                    Link(imdbID, destination: url)
                        .headline(Strings.Detail.imdbIDHeadline)
                }
                if
                    let address = mediaObject.homepageURL,
                    !address.isEmpty,
                    let homepageURL = URL(string: address)
                {
                    Link(address, destination: homepageURL)
                        .headline(Strings.Detail.homepageHeadline)
                }
                if !mediaObject.productionCompanies.isEmpty {
                    Text(mediaObject.productionCompanies.map(\.name).sorted().joined(separator: ", "))
                        .headline(Strings.Detail.productionCompaniesHeadline)
                }
                // Show exclusive data
                if let show = mediaObject as? Show {
                    if !show.networks.isEmpty {
                        Text(show.networks.map(\.name).sorted().joined(separator: ", "))
                            .headline(Strings.Detail.networksHeadline)
                    }
                    if !show.createdBy.isEmpty {
                        // Sort by last name
                        // TODO: Extract into extension .sortedByLastName
                        Text(show.createdBy.sorted(by: { name1, name2 in
                            let lastName1 = name1.components(separatedBy: .whitespaces).last
                            let lastName2 = name2.components(separatedBy: .whitespaces).last
                            // Check against empty and nil strings
                            if lastName1?.isEmpty ?? true {
                                return true
                            } else if lastName2?.isEmpty ?? true {
                                return false
                            }
                            // Sort by last name
                            return lastName1!.lexicographicallyPrecedes(lastName2!)
                        }).joined(separator: ", ")) // swiftlint:disable:this multiline_function_chains
                        .headline(Strings.Detail.createdByHeadline)
                    }
                }
                // TMDB Data
                let format: FloatingPointFormatStyle<Float> = .number.precision(.fractionLength(2))
                Text(mediaObject.popularity.formatted(format))
                    .headline(Strings.Detail.popularityHeadline)
                let avg = Double(mediaObject.voteAverage)
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
