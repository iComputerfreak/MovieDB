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
                    Text(
                        "detail.extendedInfo.header",
                        comment: "The section header for the extended information section in the detail view"
                    )
                }
            ) {
                if let tagline = mediaObject.tagline, !tagline.isEmpty {
                    Text(tagline)
                        .headline(Text(
                            "detail.extendedInfo.headline.tagline",
                            comment: "The headline for the 'tagline' property in the detail view"
                        ))
                }
                // Movie exclusive data
                if let movie = mediaObject as? Movie {
                    if movie.budget > 0 {
                        Text(movie.budget.formatted(.currency(code: "USD")))
                            .headline(Text(
                                "detail.extendedInfo.headline.budget",
                                comment: "The headline for the 'budget' property in the detail view"
                            ))
                    }
                    if movie.revenue > 0 {
                        Text(movie.revenue.formatted(.currency(code: "USD")))
                            .headline(Text(
                                "detail.extendedInfo.headline.revenue",
                                comment: "The headline for the 'revenue' property in the detail view"
                            ))
                    }
                }
                let tmdbID = mediaObject.tmdbID.description
                if let url = URL(string: "https://www.themoviedb.org/\(mediaObject.type.rawValue)/\(tmdbID)") {
                    Link("\(tmdbID)", destination: url)
                        .headline(Text(
                            "detail.extendedInfo.headline.tmdbID",
                            comment: "The headline for the 'tmdb id' property in the detail view"
                        ))
                }
                if
                    let movie = mediaObject as? Movie,
                    let imdbID = movie.imdbID,
                    let url = URL(string: "https://www.imdb.com/title/\(imdbID)")
                {
                    Link(imdbID, destination: url)
                        .headline(Text(
                            "detail.extendedInfo.headline.imdbID",
                            comment: "The headline for the 'imdb id' property in the detail view"
                        ))
                }
                if
                    let address = mediaObject.homepageURL,
                    !address.isEmpty,
                    let homepageURL = URL(string: address)
                {
                    Link(address, destination: homepageURL)
                        .headline(Text(
                            "detail.extendedInfo.headline.homepage",
                            comment: "The headline for the 'homepage' property in the detail view"
                        ))
                }
                if !mediaObject.productionCompanies.isEmpty {
                    Text(mediaObject.productionCompanies.map(\.name).sorted().joined(separator: ", "))
                        .headline(Text(
                            "detail.extendedInfo.headline.productionCompanies",
                            comment: "The headline for the 'production companies' property in the detail view"
                        ))
                }
                // Show exclusive data
                if let show = mediaObject as? Show {
                    if !show.networks.isEmpty {
                        Text(show.networks.map(\.name).sorted().joined(separator: ", "))
                            .headline(Text(
                                "detail.extendedInfo.headline.networks",
                                comment: "The headline for the 'networks' property in the detail view"
                            ))
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
                        .headline(Text(
                            "detail.extendedInfo.headline.createdBy",
                            comment: "The headline for the 'created by' property in the detail view"
                        ))
                    }
                }
                // TMDB Data
                let format: FloatingPointFormatStyle<Float> = .number.precision(.fractionLength(2))
                Text(mediaObject.popularity.formatted(format))
                    .headline(Text(
                        "detail.extendedInfo.headline.popularity",
                        comment: "The headline for the 'popularity' property in the detail view"
                    ))
                let avg = Double(mediaObject.voteAverage)
                let max: Double = 10
                let count = mediaObject.voteCount
                Text(
                    "detail.extendedInfo.scoring \(avg) \(max) \(count)",
                    // swiftlint:disable:next line_length
                    comment: "A string describing the average rating of a media object on TMDb. The first parameter is the average score/rating (0-10) as a decimal number. The second parameter is the maximum score a media object can achieve (10) as a decimal number. The third argument is the number of votes that resulted in this score."
                )
                .headline(Text(
                    "detail.extendedInfo.headline.scoring",
                    comment: "The headline for the 'scoring' property in the detail view"
                ))
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
