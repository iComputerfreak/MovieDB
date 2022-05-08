//
//  BasicInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct BasicInfo: View {
    // The formatter used to display the runtime of the movie in minutes (e.g. "130 minutes")
    private static let minutesFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.minute]
        f.unitsStyle = .full
        return f
    }()
    
    // The formatter used to display the runtime of the movie in hours and minutes (e.g. "2h 10m")
    private static let hoursFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute]
        f.unitsStyle = .abbreviated
        return f
    }()
    
    @EnvironmentObject private var mediaObject: Media
    
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            Section(header: HStack { Image(systemName: "info.circle"); Text("Basic Information") }) {
                // MARK: Genres
                if !mediaObject.genres.isEmpty {
                    Text(mediaObject.genres.map(\.name).sorted().joined(separator: ", "))
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
                        Text(releaseDate.formatted(date: .numeric, time: .omitted))
                            .headline("Release Date")
                    }
                    // MARK: Runtime
                    if let runtime = movie.runtime {
                        if runtime > 60 {
                            let components = DateComponents(calendar: .current, timeZone: .current, minute: runtime)
                            let minutesString = Self.minutesFormatter.string(from: components)!
                            let hoursString = Self.hoursFormatter.string(from: components)!
                            Text("\(minutesString) (\(hoursString))")
                                .headline("Runtime")
                        } else {
                            let formatString = NSLocalizedString(
                                "%lld Minutes",
                                tableName: "Plurals",
                                comment: "Movie Runtime"
                            )
                            Text(String.localizedStringWithFormat(formatString, runtime))
                                .headline("Runtime")
                        }
                    }
                }
                // Show exclusive data
                if mediaObject.type == .show, let show = mediaObject as? Show {
                    // MARK: Air date
                    if let firstAirDate = show.firstAirDate {
                        Text(firstAirDate.formatted(date: .numeric, time: .omitted))
                            .headline("First Aired")
                    }
                    // MARK: Last Episode / Last Aired
                    // We try to show the last episode (includes the air date)
                    if let lastEpisode = show.lastEpisodeToAir {
                        Text(episodeAirDateString(lastEpisode))
                            .headline("Last Episode")
                    // If there is no last episode available, we show the last air date, if possible
                    } else if let lastAirDate = show.lastAirDate {
                        Text(lastAirDate.formatted(date: .numeric, time: .omitted))
                            .headline("Last Aired")
                    }
                    // MARK: Next Episode
                    if let nextEpisode = show.nextEpisodeToAir {
                        Text(episodeAirDateString(nextEpisode))
                            .headline("Next Episode")
                    }
                    // MARK: Show type (e.g. Scripted)
                    if let type = show.showType {
                        // swiftlint:disable:next nslocalizedstring_key
                        Text(NSLocalizedString(type.rawValue, comment: "A type of show (e.g. Scripted)"))
                            .headline("Show Type")
                    }
                }
                // MARK: Status
                // swiftlint:disable:next nslocalizedstring_key
                Text(NSLocalizedString(
                    mediaObject.status.rawValue,
                    comment: "A status of a media (e.g. 'In Production')"
                ))
                    .headline("Status")
                // MARK: Original Title
                Text(mediaObject.originalTitle)
                    .headline("Original Title")
                // MARK: Original Language
                Text(Utils.languageString(for: mediaObject.originalLanguage) ?? mediaObject.originalLanguage)
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
    
    /// Creates a representation for a given Episode with an airDate
    ///
    /// Example:
    /// `S8E11 (15.12.2022)`
    ///
    /// - Parameter episode: The Episode to represent
    /// - Returns: The string describing the episode and its air date
    func episodeAirDateString(_ episode: Episode) -> String {
        let s = String(episode.seasonNumber)
        let e = String(episode.episodeNumber)
        if let airDate = episode.airDate {
            let formattedDate = airDate.formatted(date: .numeric, time: .omitted)
            return NSLocalizedString(
                "S\(s)E\(e) (\(formattedDate))",
                comment: "Season/Episode abbreviation for the 'next/last episode to air' field, " +
                "including the date in parentheses"
            )
        }
        return NSLocalizedString(
            "S\(s)E\(e)",
            comment: "Season/Episode abbreviation for the 'next/last episode to air' field"
        )
    }
}

struct BasicInfo_Previews: PreviewProvider {
    static var previews: some View {
        List {
            BasicInfo()
        }
            .environmentObject(PlaceholderData.movie as Media)
        
        List {
            BasicInfo()
        }
        .environmentObject(PlaceholderData.show as Media)
    }
}
