//
//  BasicInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct BasicInfo: View {
    
    @EnvironmentObject private var mediaObject: Media
    
    private var movieData: TMDBMovieData? {
        mediaObject.tmdbData as? TMDBMovieData
    }
    
    private var showData: TMDBShowData? {
        mediaObject.tmdbData as? TMDBShowData
    }
    
    var body: some View {
        mediaObject.tmdbData.map { (data: TMDBData) in
            Section(header: Text("Basic Information")) {
                Text(String(format: "%04d", mediaObject.id))
                    .headline("ID")
                if !data.genres.isEmpty {
                    Text(data.genres.map({ $0.name }).joined(separator: ", "))
                        .headline("Genres")
                }
                data.overview.map {
                    LongTextView($0, headline: "Description")
                        .headline("Description")
                }
                // Movie exclusive data
                if (movieData != nil) {
                    movieData!.releaseDate.map { (releaseDate: Date) in
                        Text(JFUtils.dateFormatter.string(from: releaseDate))
                            .headline("Release Date")
                    }
                    movieData!.runtime.map { (runtime: Int) in
                        Text("\(runtime) Minutes (\(runtime / 60):\(runtime % 60) h)")
                            .headline("Runtime")
                    }
                }
                // Show exclusive data
                if (showData != nil) {
                    showData!.firstAirDate.map { (firstAirDate: Date) in
                        showData!.lastAirDate.map { (lastAirDate: Date) in
                            Text("\(JFUtils.dateFormatter.string(from: firstAirDate)) - \(JFUtils.dateFormatter.string(from: lastAirDate))")
                                .headline("Air Date")
                        }
                    }
                    // Redundant with "Status"
                    //Text(showData!.isInProduction ? "Yes" : "No")
                    //    .headline("In Production?")
                    Text(showData!.type)
                        .headline("Show Type")
                }
                Text(data.status)
                    .headline("Status")
                Text(data.originalTitle)
                    .headline("Original Title")
                Text(JFUtils.languageString(data.originalLanguage))
                    .headline("Original Language")
                // Seasons Info
                if showData != nil && !showData!.seasons.isEmpty {
                    NavigationLink(destination: SeasonsInfo()) {
                        Text("\(showData!.seasons.count) Seasons")
                            .headline("Seasons")
                    }
                }
            }
        }
    }
}

struct BasicInfo_Previews: PreviewProvider {
    static var previews: some View {
        BasicInfo()
    }
}
