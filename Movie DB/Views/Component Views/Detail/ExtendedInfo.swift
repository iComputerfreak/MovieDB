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
            Section(header: HStack { Image(systemName: "ellipsis.circle.fill"); Text("Extended Information") }) {
                // Movie exclusive data
                if let movie = mediaObject as? Movie {
                    if let tagline = movie.tagline, !tagline.isEmpty {
                        Text(tagline)
                            .headline("Tagline")
                    }
                    if movie.budget > 0 {
                        Text(JFUtils.moneyFormatter.string(from: movie.budget)!)
                            .headline("Budget")
                    }
                    if movie.revenue > 0 {
                        Text(JFUtils.moneyFormatter.string(from: movie.revenue)!)
                            .headline("Revenue")
                    }
                    if let imdbID = movie.imdbID {
                        LinkView(text: imdbID, link: "https://www.imdb.com/title/\(imdbID)")
                            .headline("IMDB ID")
                    }
                }
                
                LinkView(text: String(mediaObject.tmdbID), link: "https://www.themoviedb.org/\(mediaObject.type.rawValue)/\(mediaObject.tmdbID)")
                    .headline("TMDB ID")
                if let homepageURL = mediaObject.homepageURL, !homepageURL.isEmpty {
                    LinkView(text: homepageURL, link: homepageURL)
                        .headline("Homepage")
                }
                if !mediaObject.productionCompanies.isEmpty {
                    Text(String(mediaObject.productionCompanies.map(\.name).joined(separator: ", ")))
                        .headline("Production Companies")
                }
                // Show exclusive data
                if let show = mediaObject as? Show {
                    if !show.networks.isEmpty {
                        Text(show.networks.map(\.name).joined(separator: ", "))
                            .headline("Networks")
                    }
                }
                // TMDB Data
                Text(String.localizedStringWithFormat("%.2f", mediaObject.popularity))
                    .headline("Popularity")
                Text("\(mediaObject.voteAverage)/10.0 points from \(mediaObject.voteCount) votes")
                    .headline("Scoring")
            }
        }
    }
}

struct ExtendedInfo_Previews: PreviewProvider {
    static var previews: some View {
        ExtendedInfo()
    }
}
