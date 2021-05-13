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
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            Section(header: HStack { Image(systemName: "info.circle.fill"); Text("Basic Information") }) {
                // MARK: Genres
                if !mediaObject.genres.isEmpty {
                    Text(mediaObject.genres.map(\.name).joined(separator: ", "))
                        .headline("Genres")
                }
                // MARK: Overview
                if let overview = mediaObject.overview, !overview.isEmpty {
                    LongTextView(overview, headlineKey: "Description")
                        .headline("Description")
                        .fixHighlighting()
                }
                // Movie exclusive data
                if mediaObject.type == .movie, let movie = mediaObject as? Movie {
                    // MARK: Release Date
                    if let releaseDate = movie.releaseDate {
                        Text(JFUtils.dateFormatter.string(from: releaseDate))
                            .headline("Release Date")
                    }
                    // MARK: Runtime
                    if let runtime = movie.runtime {
                        if runtime > 60 {
                            let formatString = NSLocalizedString("%lld Minutes (%lldh %lldm)", tableName: "Plurals", comment: "Movie Runtime")
                            Text(String.localizedStringWithFormat(formatString, runtime, runtime / 60, runtime % 60))
                                .headline("Runtime")
                        } else {
                            let formatString = NSLocalizedString("%lld Minutes", tableName: "Plurals", comment: "Movie Runtime")
                            Text(String.localizedStringWithFormat(formatString, runtime))
                                .headline("Runtime")
                        }
                    }
                }
                // Show exclusive data
                if mediaObject.type == .show, let show = mediaObject as? Show {
                    // MARK: Air date
                    if let firstAirDate = show.firstAirDate,
                       let lastAirDate = show.lastAirDate {
                        // Cast to string to prevent localization
                        Text("\(JFUtils.dateFormatter.string(from: firstAirDate)) - \(JFUtils.dateFormatter.string(from: lastAirDate))" as String)
                            .headline("Air Date")
                    }
                    // MARK: Show type (e.g. Scripted)
                    if let type = show.showType {
                        Text(NSLocalizedString(type.rawValue))
                            .headline("Show Type")
                    }
                }
                // MARK: Status
                Text(NSLocalizedString(mediaObject.status.rawValue))
                    .headline("Status")
                // MARK: Original Title
                Text(mediaObject.originalTitle)
                    .headline("Original Title")
                // MARK: Original Language
                Text(JFUtils.languageString(for: mediaObject.originalLanguage) ?? mediaObject.originalLanguage)
                    .headline("Original Language")
                // MARK: Seasons
                if mediaObject.type == .show, let show = mediaObject as? Show, !show.seasons.isEmpty {
                    NavigationLink(destination: SeasonsInfo().environmentObject(mediaObject)) {
                        // Use the highest seasonNumber, not number of elements, since there could be "Specials" seasons which do not count to the normal seasons
                        Text("\(show.seasons.map(\.seasonNumber).max() ?? 0) Seasons", tableName: "Plurals")
                            .headline("Seasons")
                    }
                    .fixHighlighting()
                }
                // MARK: Cast
                if !mediaObject.cast.isEmpty {
                    NavigationLink(destination: CastInfo().environmentObject(mediaObject)) {
                        Text("Cast")
                    }
                    .fixHighlighting()
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
