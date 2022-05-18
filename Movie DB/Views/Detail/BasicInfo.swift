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
            Section(
                header: HStack {
                    Image(systemName: "info.circle")
                    Text(
                        "detail.basicInfo.header",
                        comment: "The section header for the basic information section in the detail view"
                    )
                }
            ) {
                // MARK: Genres
                if !mediaObject.genres.isEmpty {
                    Text(mediaObject.genres.map(\.name).sorted().joined(separator: ", "))
                        .headline(
                            "detail.basicInfo.headline.genres",
                            comment: "The headline for the 'genres' property in the detail view"
                        )
                }
                // MARK: Overview
                if let overview = mediaObject.overview, !overview.isEmpty {
                    LongTextView(overview, headlineKey: "Description")
                        .headline(
                            "detail.basicInfo.headline.description",
                            comment: "The headline for the 'description' property in the detail view"
                        )
                        .fixHighlighting()
                }
                // Movie exclusive data
                if mediaObject.type == .movie, let movie = mediaObject as? Movie {
                    // MARK: Release Date
                    if let releaseDate = movie.releaseDate {
                        Text(releaseDate.formatted(date: .numeric, time: .omitted))
                            .headline(
                                "detail.basicInfo.headline.releaseDate",
                                comment: "The headline for the 'release date' property in the detail view"
                            )
                    }
                    // MARK: Runtime
                    if let runtime = movie.runtime {
                        if runtime > 60 {
                            let components = DateComponents(calendar: .current, timeZone: .current, minute: runtime)
                            let minutesString = Self.minutesFormatter.string(from: components)!
                            let hoursString = Self.hoursFormatter.string(from: components)!
                            Text(
                                "detail.basicInfo.runtime.minutesAndHours \(minutesString) \(hoursString)",
                                // swiftlint:disable:next line_length
                                comment: "A string that displays a formatted duration in minutes and hours/minutes. E.g. '90 minutes (1h 30m)'. The first parameter is the formatted duration string in minutes. The second parameter is the formatted duration string in hours and minutes."
                            )
                            .headline(
                                "detail.basicInfo.headline.runtime",
                                comment: "The headline for the 'runtime' property in the detail view"
                            )
                        } else {
                            let components = DateComponents(calendar: .current, timeZone: .current, minute: runtime)
                            Text(Self.minutesFormatter.string(from: components)!)
                                .headline(
                                    "detail.basicInfo.headline.runtime",
                                    comment: "The headline for the 'runtime' property in the detail view"
                                )
                        }
                    }
                }
                // Show exclusive data
                if mediaObject.type == .show, let show = mediaObject as? Show {
                    // MARK: Air date
                    if let firstAirDate = show.firstAirDate {
                        Text(firstAirDate.formatted(date: .numeric, time: .omitted))
                            .headline(
                                "detail.basicInfo.headline.firstAired",
                                comment: "The headline for the 'first aired' property in the detail view"
                            )
                    }
                    // MARK: Last Episode / Last Aired
                    // We try to show the last episode (includes the air date)
                    if let lastEpisode = show.lastEpisodeToAir {
                        Text(episodeAirDateString(lastEpisode))
                            .headline(
                                "detail.basicInfo.headline.lastEpisode",
                                comment: "The headline for the 'last episode' property in the detail view"
                            )
                    // If there is no last episode available, we show the last air date, if possible
                    } else if let lastAirDate = show.lastAirDate {
                        Text(lastAirDate.formatted(date: .numeric, time: .omitted))
                            .headline(
                                "detail.basicInfo.headline.lastAired",
                                comment: "The headline for the 'last aired' property in the detail view"
                            )
                    }
                    // MARK: Next Episode
                    if let nextEpisode = show.nextEpisodeToAir {
                        Text(episodeAirDateString(nextEpisode))
                            .headline(
                                "detail.basicInfo.headline.nextEpisode",
                                comment: "The headline for the 'next episode' property in the detail view"
                            )
                    }
                    // MARK: Show type (e.g. Scripted)
                    if let type = show.showType {
                        Text(type.localized)
                            .headline(
                                "detail.basicInfo.headline.showType",
                                comment: "The headline for the 'show type' property in the detail view"
                            )
                    }
                }
                // MARK: Status
                Text(mediaObject.status.localized)
                    .headline(
                        "detail.basicInfo.headline.status",
                        comment: "The headline for the 'status' property in the detail view"
                    )
                // MARK: Original Title
                Text(mediaObject.originalTitle)
                    .headline(
                        "detail.basicInfo.headline.originalTitle",
                        comment: "The headline for the 'original title' property in the detail view"
                    )
                // MARK: Original Language
                Text(Utils.languageString(for: mediaObject.originalLanguage) ?? mediaObject.originalLanguage)
                    .headline(
                        "detail.basicInfo.headline.originalLanguage",
                        comment: "The headline for the 'original language' property in the detail view"
                    )
                // MARK: Seasons
                if mediaObject.type == .show, let show = mediaObject as? Show, !show.seasons.isEmpty {
                    NavigationLink(destination: SeasonsInfo().environmentObject(mediaObject)) {
                        // Use the highest seasonNumber, not number of elements, since there could be "Specials" seasons which do not count to the normal seasons
                        let maxSeasonNumber = show.seasons.map(\.seasonNumber).max() ?? 0
                        Text(
                            "detail.basicInfo.seasonCount \(maxSeasonNumber)",
                            comment: "A string that describes the number of seasons of a tv show in the media detail"
                        )
                        .headline(
                            "detail.basicInfo.headline.seasons",
                            comment: "The headline for the 'seasons' property in the detail view"
                        )
                    }
                    .fixHighlighting()
                }
                // MARK: Cast
                if !mediaObject.cast.isEmpty {
                    NavigationLink(destination: CastInfo().environmentObject(mediaObject)) {
                        Text(
                            "detail.basicInfo.cast",
                            // swiftlint:disable:next line_length
                            comment: "The button label in the detail of a media object that leads to the cast information."
                        )
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
            return String(
                localized: "detail.episodeAirDate \(s) \(e) \(formattedDate)",
                // swiftlint:disable:next line_length
                comment: "Season/Episode abbreviation for the 'next/last episode to air' field, including the date. First argument: season number, second argument: episode number, third argument: formatted date"
            )
        }
        return String(
            localized: "detail.episodeAirDate \(s) \(e)",
            // swiftlint:disable:next line_length
            comment: "Season/Episode abbreviation for the 'next/last episode to air' field, without a date. First argument: season number, second argument: episode number"
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
