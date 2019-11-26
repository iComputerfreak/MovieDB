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
    
    private var movieData: TMDBMovieData? {
        mediaObject.tmdbData as? TMDBMovieData
    }
    
    private var showData: TMDBShowData? {
        mediaObject.tmdbData as? TMDBShowData
    }
    
    var body: some View {
        mediaObject.tmdbData.map { (data: TMDBData) in
            Section(header: Text("Extended Information")) {
                // Movie exclusive data
                if movieData != nil {
                    movieData!.tagline.map {
                        Text($0)
                            .headline("Tagline")
                    }
                    if movieData!.budget > 0 {
                        Text(JFUtils.moneyFormatter.string(from: movieData!.budget)!)
                            .headline("Budget")
                    }
                    if movieData!.revenue > 0 {
                        Text(JFUtils.moneyFormatter.string(from: movieData!.revenue)!)
                            .headline("Revenue")
                    }
                }
                
                // FIXME: Not always correct
                LinkView(text: String(data.id), link: "https://www.themoviedb.org/movie/\(data.id)")
                    .headline("TMDB ID")
                data.imdbID.map {
                    LinkView(text: $0, link: "https://www.imdb.com/title/\($0)")
                        .headline("IMDB ID")
                }
                if (data.homepageURL != nil && !data.homepageURL!.isEmpty) {
                    LinkView(text: data.homepageURL!, link: data.homepageURL!)
                        .headline("Homepage")
                }
                if !data.productionCompanies.isEmpty {
                    Text(String(data.productionCompanies.map({ $0.name }).joined(separator: ", ")))
                        .headline("Production Companies")
                }
                // Show exclusive data
                if showData != nil {
                    if !showData!.networks.isEmpty {
                        Text(showData!.networks.map({ $0.name }).joined(separator: ", "))
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
