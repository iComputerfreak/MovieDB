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
            Text(String(format: "%04d", mediaObject.id))
                .headline("ID")
            if !mediaObject.genres.isEmpty {
                Text(mediaObject.genres.map(\.name).joined(separator: ", "))
                    .headline("Genres")
            }
            if let overview = mediaObject.overview, !overview.isEmpty {
                LongTextView(overview, headline: "Description")
                    .headline("Description")
            }
            // Movie exclusive data
            if mediaObject.type == .movie, let movie = mediaObject as? Movie {
                if let releaseDate = movie.releaseDate {
                    Text(JFUtils.dateFormatter.string(from: releaseDate))
                        .headline("Release Date")
                }
                if let runtime = movie.runtime {
                    Text("\(runtime) Minutes (\(runtime >= 60 ? "\(runtime / 60)h " : "")\(runtime % 60)m)")
                        .headline("Runtime")
                }
            }
            // Show exclusive data
            if mediaObject.type == .show, let show = mediaObject as? Show {
                // Air date
                if let firstAirDate = show.firstAirDate,
                   let lastAirDate = show.lastAirDate {
                    Text("\(JFUtils.dateFormatter.string(from: firstAirDate)) - \(JFUtils.dateFormatter.string(from: lastAirDate))")
                        .headline("Air Date")
                }
                // Show type (e.g. Scripted)
                if let type = show.showType {
                    Text(type.rawValue)
                        .headline("Show Type")
                }
            }
            Text(mediaObject.status.rawValue)
                .headline("Status")
            Text(mediaObject.originalTitle)
                .headline("Original Title")
            Text(JFUtils.languageString(for: mediaObject.originalLanguage) ?? mediaObject.originalLanguage)
                .headline("Original Language")
            // Seasons Info
            if mediaObject.type == .show, let show = mediaObject as? Show, !show.seasons.isEmpty {
                NavigationLink(destination: SeasonsInfo().environmentObject(mediaObject)) {
                    Text("\(show.seasons.count) Seasons")
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

struct BasicInfo_Previews: PreviewProvider {
    static var previews: some View {
        BasicInfo()
    }
}
