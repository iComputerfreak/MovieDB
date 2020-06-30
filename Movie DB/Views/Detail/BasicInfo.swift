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
    
    var body: some View {
        Section(header: HStack { Image(systemName: "info.circle.fill"); Text("Basic Information") }) {
            if let data = mediaObject.tmdbData {
                Text(String(format: "%04d", mediaObject.id))
                    .headline("ID")
                if !data.genres.isEmpty {
                    Text(data.genres.map(\.name).joined(separator: ", "))
                        .headline("Genres")
                }
                if let overview = data.overview, !overview.isEmpty {
                    LongTextView(overview, headline: "Description")
                        .headline("Description")
                }
                // Movie exclusive data
                if let movieData = data as? TMDBMovieData {
                    if let releaseDate = movieData.releaseDate {
                        Text(JFUtils.dateFormatter.string(from: releaseDate))
                            .headline("Release Date")
                    }
                    if let runtime = movieData.runtime {
                        Text("\(runtime) Minutes (\(runtime >= 60 ? "\(runtime / 60)h " : "")\(runtime % 60)m)")
                            .headline("Runtime")
                    }
                }
                // Show exclusive data
                if let showData = data as? TMDBShowData {
                    // Air date
                    if let firstAirDate = showData.firstAirDate,
                       let lastAirDate = showData.lastAirDate {
                        Text("\(JFUtils.dateFormatter.string(from: firstAirDate)) - \(JFUtils.dateFormatter.string(from: lastAirDate))")
                            .headline("Air Date")
                    }
                    // Show type (e.g. Scripted)
                    if let type = showData.type {
                        Text(type.rawValue)
                            .headline("Show Type")
                    }
                }
                Text(data.status.rawValue)
                    .headline("Status")
                Text(data.originalTitle)
                    .headline("Original Title")
                Text(JFUtils.languageString(for: data.originalLanguage) ?? data.originalLanguage)
                    .headline("Original Language")
                // Seasons Info
                if let showData = data as? TMDBShowData, !showData.seasons.isEmpty {
                    NavigationLink(destination: SeasonsInfo().environmentObject(mediaObject)) {
                        Text("\(showData.seasons.count) Seasons")
                            .headline("Seasons")
                    }
                }
                // Cast
                if !mediaObject.cast.isEmpty {
                    NavigationLink(destination: CastInfo().environmentObject(mediaObject)) {
                        Text("Cast")
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
