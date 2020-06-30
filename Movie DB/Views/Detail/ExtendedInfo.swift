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
        Section(header: HStack { Image(systemName: "ellipsis.circle.fill"); Text("Extended Information") }) {
            if let data = mediaObject.tmdbData {
                // Movie exclusive data
                if let movieData = data as? TMDBMovieData {
                    if let tagline = movieData.tagline, !tagline.isEmpty {
                        Text(tagline)
                            .headline("Tagline")
                    }
                    if movieData.budget > 0 {
                        Text(JFUtils.moneyFormatter.string(from: movieData.budget)!)
                            .headline("Budget")
                    }
                    if movieData.revenue > 0 {
                        Text(JFUtils.moneyFormatter.string(from: movieData.revenue)!)
                            .headline("Revenue")
                    }
                }
                
                LinkView(text: String(data.id), link: "https://www.themoviedb.org/\(mediaObject.type.rawValue)/\(data.id)")
                    .headline("TMDB ID")
                if let imdbID = data.imdbID {
                    LinkView(text: imdbID, link: "https://www.imdb.com/title/\(imdbID)")
                        .headline("IMDB ID")
                }
                if let homepageURL = data.homepageURL, !homepageURL.isEmpty {
                    LinkView(text: homepageURL, link: homepageURL)
                        .headline("Homepage")
                }
                if !data.productionCompanies.isEmpty {
                    Text(String(data.productionCompanies.map(\.name).joined(separator: ", ")))
                        .headline("Production Companies")
                }
                // Show exclusive data
                if let showData = data as? TMDBShowData {
                    if !showData.networks.isEmpty {
                        Text(showData.networks.map(\.name).joined(separator: ", "))
                            .headline("Networks")
                    }
                }
                // TMDB Data
                Text(String(data.popularity))
                    .headline("Popularity")
                Text("\(String(format: "%.1f", data.voteAverage))/10.0 points from \(data.voteCount) votes")
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
