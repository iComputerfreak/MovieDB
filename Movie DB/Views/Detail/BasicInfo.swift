//
//  BasicInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import os.log
import SwiftUI

struct BasicInfo: View {
    @EnvironmentObject private var mediaObject: Media
    
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            Section(
                header: HStack {
                    Image(systemName: "info.circle")
                    Text(Strings.Detail.basicInfoSectionHeader)
                }
            ) {
                // MARK: Genres
                if !mediaObject.genres.isEmpty {
                    Text(
                        mediaObject.genres
                            .map(\.name)
                            .sorted()
                            .joined(separator: ", ")
                    )
                    .headline(Strings.Detail.genresHeadline)
                }
                // MARK: Overview
                if let overview = mediaObject.overview, !overview.isEmpty {
                    LongTextView(
                        overview,
                        headline: Strings.Detail.descriptionHeadline
                    )
                }
                // Movie exclusive data
                if mediaObject.type == .movie, let movie = mediaObject as? Movie {
                    // MARK: Release Date
                    if let releaseDate = movie.releaseDate {
                        Text(releaseDate.formatted(date: .numeric, time: .omitted))
                            .headline(Strings.Detail.releaseDateHeadline)
                    }
                    // MARK: Runtime
                    RuntimeInfoView()
                }
                // Show exclusive data
                if mediaObject.type == .show, let show = mediaObject as? Show {
                    // MARK: Air date
                    if let firstAirDate = show.firstAirDate {
                        Text(firstAirDate.formatted(date: .numeric, time: .omitted))
                            .headline(Strings.Detail.firstAiredHeadline)
                    }
                    // MARK: Last Episode / Last Aired
                    // We try to show the last episode (includes the air date)
                    if let lastEpisode = show.lastEpisodeToAir {
                        Text(episodeAirDateString(lastEpisode))
                            .headline(Strings.Detail.lastEpisodeHeadline)
                    } else if let lastAirDate = show.lastAirDate {
                        // If there is no last episode available, we show the last air date, if possible
                        Text(lastAirDate.formatted(date: .numeric, time: .omitted))
                            .headline(Strings.Detail.lastAiredHeadline)
                    }
                    // MARK: Next Episode
                    if let nextEpisode = show.nextEpisodeToAir {
                        Text(episodeAirDateString(nextEpisode))
                            .headline(Strings.Detail.nextEpisodeHeadline)
                    }
                    // MARK: Show type (e.g. Scripted)
                    if let type = show.showType {
                        Text(type.localized)
                            .headline(Strings.Detail.showTypeHeadline)
                    }
                }
                // MARK: Status
                Text(mediaObject.status.localized)
                    .headline(Strings.Detail.mediaStatusHeadline)
                // MARK: Original Title
                Text(mediaObject.originalTitle)
                    .headline(Strings.Detail.originalTitleHeadline)
                // MARK: Original Language
                Text(Utils.languageString(for: mediaObject.originalLanguage) ?? mediaObject.originalLanguage)
                    .headline(Strings.Detail.originalLanguageHeadline)
                // MARK: Production Countries
                if !mediaObject.productionCountries.isEmpty {
                    Text(
                        mediaObject.productionCountries
                            .map { code in
                                Locale.current.localizedString(forRegionCode: code) ?? Strings.Generic.unknown
                            }
                            .sorted()
                            .formatted()
                    )
                    .headline(Strings.Detail.productionCountriesHeadline)
                }
                // MARK: Seasons
                if mediaObject.type == .show, let show = mediaObject as? Show, !show.seasons.isEmpty {
                    NavigationLink {
                        SeasonsInfo()
                            .environmentObject(mediaObject)
                    } label: {
                        // Use the highest seasonNumber, not number of elements, since there could be "Specials" seasons which do not count to the normal seasons
                        let maxSeasonNumber = show.seasons.map(\.seasonNumber).max() ?? 0
                        Text(Strings.Detail.seasonCountLabel(maxSeasonNumber))
                            .headline(Strings.Detail.seasonsHeadline)
                    }
                } else {
                    EmptyView()
                        .onAppear {
                            Logger.detail.debug("Show \(mediaObject.title) has no seasons to display.")
                        }
                }
                // MARK: Directors
                if !mediaObject.directors.isEmpty {
                    Text(mediaObject.directors.joined(separator: ", "))
                        .headline(
                            // swiftlint:disable:next line_length
                            mediaObject.directors.count == 1 ? Strings.Detail.directorLabel : Strings.Detail.directorsLabel
                        )
                }
                // MARK: Cast
                NavigationLink {
                    CastInfo()
                        .environmentObject(mediaObject)
                } label: {
                    Text(Strings.Detail.castLabel)
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
        let s = episode.seasonNumber
        let e = episode.episodeNumber
        if let airDate = episode.airDate {
            let formattedDate = airDate.formatted(date: .numeric, time: .omitted)
            return Strings.Detail.episodeAirDateWithDate(s, e, formattedDate)
        }
        return Strings.Detail.episodeAirDate(s, e)
    }
}

struct BasicInfo_Previews: PreviewProvider {
    static var previews: some View {
        List {
            BasicInfo()
        }
        .environmentObject(PlaceholderData.preview.staticMovie as Media)
        
        List {
            BasicInfo()
        }
        .environmentObject(PlaceholderData.preview.staticShow as Media)
    }
}
