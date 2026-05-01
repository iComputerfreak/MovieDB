// Copyright © 2019 Jonas Frey. All rights reserved.

import os.log
import SwiftUI

struct BasicInfoSection: View {
    @EnvironmentObject private var mediaObject: Media

    private var genresString: String {
        mediaObject.genres
            .map(\.name)
            .sorted()
            .joined(separator: ", ")
    }

    private var productionCountriesString: String {
        mediaObject.productionCountries
            .map { code in
                Locale.current.localizedString(forRegionCode: code) ?? Strings.Generic.unknown
            }
            .sorted()
            .formatted()
    }

    private var createdByString: String? {
        guard
            let createdBy = (mediaObject as? Show)?.createdBy,
            !createdBy.isEmpty
        else { return nil }

        return createdBy
            // Sorted by last name
            .sorted(using: LastNameComparator(order: .forward))
            .formatted()
    }

    private var movieDirectorsString: String? {
        guard
            let movie = mediaObject as? Movie,
            !movie.directors.isEmpty
        else { return nil }

        return movie.directors
            .sorted(using: LastNameComparator(order: .forward))
            .formatted()
    }

    private var movieDirectorCount: Int {
        (mediaObject as? Movie)?.directors.count ?? 0
    }

    var body: some View {
        GroupBoxSection(title: Strings.Detail.basicInfoSectionHeader) {
            // MARK: Genres
            if !mediaObject.genres.isEmpty {
                Text(genresString)
                    .headline(Image(systemName: "theatermasks"), Strings.Detail.genresHeadline)
            }

            if let movie = mediaObject as? Movie {
                // MARK: Release Date
                if let releaseDate = movie.releaseDate {
                    Text(releaseDate.formatted(date: .long, time: .omitted))
                        .headline(Image(systemName: "calendar"), Strings.Detail.releaseDateHeadline)
                }

                // MARK: Runtime
                RuntimeInfoView()
            }
            // Show exclusive data
            if let show = mediaObject as? Show {
                // MARK: Air date
                if let firstAirDate = show.firstAirDate {
                    Text(firstAirDate.formatted(date: .long, time: .omitted))
                        .headline(Image(systemName: "sparkles.tv"), Strings.Detail.firstAiredHeadline)
                }

                // MARK: Last Episode / Last Aired
                // We try to show the last episode (includes the air date)
                if let lastEpisode = show.lastEpisodeToAir {
                    Text(episodeAirDateString(lastEpisode))
                        .headline(Image(systemName: "tv"), Strings.Detail.lastEpisodeHeadline)
                } else if let lastAirDate = show.lastAirDate {
                    // If there is no last episode available, we show the last air date, if possible
                    Text(lastAirDate.formatted(date: .long, time: .omitted))
                        .headline(Image(systemName: "tv"), Strings.Detail.lastAiredHeadline)
                }

                // MARK: Next Episode
                if let nextEpisode = show.nextEpisodeToAir {
                    Text(episodeAirDateString(nextEpisode))
                        .headline(Image(systemName: "play.tv"), Strings.Detail.nextEpisodeHeadline)
                }

                // MARK: Show type (e.g. Scripted)
                if let type = show.showType {
                    Text(type.localized)
                        .headline(Image(systemName: "film.stack"), Strings.Detail.showTypeHeadline)
                }
            }

            // MARK: Status
            Text(mediaObject.status.localized)
                .headline(Image(systemName: "clock.arrow.circlepath"), Strings.Detail.mediaStatusHeadline)

            // MARK: Original Title
            Text(mediaObject.originalTitle)
                .headline(Image(systemName: "textformat"), Strings.Detail.originalTitleHeadline)

            // MARK: Original Language
            Text(Utils.languageString(for: mediaObject.originalLanguage) ?? mediaObject.originalLanguage)
                .headline(Image(systemName: "ellipsis.message"), Strings.Detail.originalLanguageHeadline)

            // MARK: Production Countries
            if !mediaObject.productionCountries.isEmpty {
                Text(productionCountriesString)
                .headline(Image(systemName: "globe.europe.africa"), Strings.Detail.productionCountriesHeadline)
            }

            // MARK: Created By
            if let createdByString {
                Text(createdByString)
                    .headline(Image(systemName: "movieclapper.fill"), Strings.Detail.createdByHeadline)
            }

            // MARK: Seasons
            if let show = mediaObject as? Show, !show.seasons.isEmpty {
                NavigationLink {
                    SeasonsDetailView()
                        .environmentObject(mediaObject)
                } label: {
                    // Use the highest seasonNumber, not number of elements, since there could be "Specials" seasons which do not count to the normal seasons
                    let maxSeasonNumber = show.seasons.map(\.seasonNumber).max() ?? 0
                    Text(Strings.Detail.seasonCountLabel(maxSeasonNumber))
                        .headline(Image(systemName: "list.number"), Strings.Detail.seasonsHeadline)
                }
            }

            // MARK: Directors
            if let movieDirectorsString {
                Text(movieDirectorsString)
                    .headline(
                        Image(systemName: "movieclapper.fill"),
                        movieDirectorCount == 1 ? Strings.Detail.directorLabel : Strings.Detail.directorsLabel
                    )
            }

            // MARK: Cast
            NavigationLink {
                CastDetailView()
                    .environmentObject(mediaObject)
            } label: {
                HStack(spacing: 4) {
                    Text(Strings.Detail.viewCastMembersLabel)
                    Image(systemName: "chevron.right")
                }
            }
            .headline(Image(systemName: "person.3.fill"), Strings.Detail.castLabel)
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

#Preview("Movie") {
    NavigationStack {
        VStack(alignment: .leading) {
            BasicInfoSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticMovie as Media)
}

#Preview("Show") {
    NavigationStack {
        VStack(alignment: .leading) {
            BasicInfoSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticShow as Media)
}
