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
            Section(header: HStack { Image(systemName: "ellipsis.circle"); Text("Extended Information") }) {
                if let tagline = mediaObject.tagline, !tagline.isEmpty {
                    Text(tagline)
                        .headline("Tagline")
                }
                // Movie exclusive data
                if let movie = mediaObject as? Movie {
                    if movie.budget > 0 {
                        Text(movie.budget.formatted(.currency(code: "USD")))
                            .headline("Budget")
                    }
                    if movie.revenue > 0 {
                        Text(movie.revenue.formatted(.currency(code: "USD")))
                            .headline("Revenue")
                    }
                    if let imdbID = movie.imdbID {
                        LinkView(text: imdbID, link: "https://www.imdb.com/title/\(imdbID)")
                            .headline("IMDB ID")
                    }
                }
                let tmdbID = String(mediaObject.tmdbID)
                LinkView(
                    text: tmdbID,
                    link: "https://www.themoviedb.org/\(mediaObject.type.rawValue)/\(tmdbID)"
                )
                .headline("TMDB ID")
                if let homepageURL = mediaObject.homepageURL, !homepageURL.isEmpty {
                    LinkView(text: homepageURL, link: homepageURL)
                        .headline("Homepage")
                }
                if !mediaObject.productionCompanies.isEmpty {
                    Text(String(mediaObject.productionCompanies.map(\.name).sorted().joined(separator: ", ")))
                        .headline("Production Companies")
                }
                // Show exclusive data
                if let show = mediaObject as? Show {
                    if !show.networks.isEmpty {
                        Text(show.networks.map(\.name).sorted().joined(separator: ", "))
                            .headline("Networks")
                    }
                    if !show.createdBy.isEmpty {
                        // Sort by last name
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
                            .headline("Created by")
                    }
                }
                // TMDB Data
                let format: FloatingPointFormatStyle<Float> = .number.precision(.fractionLength(2))
                Text(mediaObject.popularity.formatted(format))
                    .headline("Popularity")
                let avg = mediaObject.voteAverage.formatted(format)
                let max = 10.formatted(.number.precision(.fractionLength(0)))
                let count = mediaObject.voteCount.formatted()
                Text("\(avg)/\(max) points from \(count) votes")
                    .headline("Scoring")
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
