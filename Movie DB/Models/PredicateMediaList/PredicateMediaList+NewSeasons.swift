//
//  PredicateMediaList+NewSeasons.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation

extension PredicateMediaList {
    /// A media list that features shows with new unwatched seasons
    static let newSeasons = PredicateMediaList(
        name: Strings.Lists.defaultListNameNewSeasons,
        subtitleContentUserDefaultsKey: "newSeasonsSubtitleContent",
        defaultSubtitleContent: .watchState,
        description: Strings.Lists.newSeasonsDescription,
        iconName: "sparkles.tv",
        predicate: NSCompoundPredicate(type: .and, subpredicates: [
            // Only shows that have been started watching
            ShowWatchState.showsWatchedAnyPredicate,
            
            // More seasons available than watched
            // !!!: This is a conservative approximation and will return more results than we want, because it includes
            // !!!: shows, where a new season is planned, but no episodes are available.
            // !!!: (show.seasons.max(on: \.seasonNumber, by: <).episodeCount == 0)
            
            // Ideally, we would want something like this:
            // let maxSeason = SELECT max(seasonNumber) FROM seasons WHERE episodeCount > 0
            // NSPredicate(format: "lastSeasonWatched < \(maxSeason)")
            
            // Since that is not possible using a single predicate (although it would probably be possible using a
            // NSFetchRequest; see MediaLibrary.problems()), we include a filter that filters out the excess seasons
            // after fetching.
            NSPredicate(
                format: "%K < %K",
                Schema.Show.lastSeasonWatched,
                Schema.Show.numberOfSeasons
            ),
            
            // Don't include shows marked as "Watch Again?" = false
            NSPredicate(
                format: "%K = %@ OR %K = nil",
                Schema.Media.watchAgain,
                true as NSNumber,
                Schema.Media.watchAgain
            ),
        ]),
        customFilter: { media in
            if
                let show = media as? Show,
                let latestNonEmptySeasonNumber = show.latestNonEmptySeasonNumber,
                let watched = show.watched
            {
                // MARK: Only include shows where the latestNonEmptySeasonNumber has not been watched yet
                guard watched < ShowWatchState.season(latestNonEmptySeasonNumber) else { return false }
                
                // MARK: Don't include shows where the unwatched seasons are in the future
                let lastFullyWatchedSeason: Int? = {
                    switch watched {
                    case .season(let season):
                        return season
                    case .episode(let season, let episode):
                        return season == 1 ? nil : season - 1
                    case .notWatched:
                        return nil
                    }
                }()
                let latestNonFutureSeason: Int? = show.seasons
                    .filter { season in
                        guard let airDate = season.airDate else {
                            // Count seasons without an airDate as "non-future"
                            return true
                        }
                        return airDate < .now
                    }
                    .map(\.seasonNumber)
                    .max()
                
                guard lastFullyWatchedSeason != nil else {
                    // If we never even watched a whole season, include the media
                    return true
                }
                guard latestNonFutureSeason != nil, latestNonFutureSeason! > 0 else {
                    // If there are no seasons that are available right now, don't include the media
                    return false
                }
                // Only include the media if there is at least one season that has already aired and is not watched
                return lastFullyWatchedSeason! < latestNonFutureSeason!
            }
            // Results that are not shows or have missing data are not filtered out
            return true
        }
    )
}
