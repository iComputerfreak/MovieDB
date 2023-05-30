//
//  PredicateMediaLists.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import JFUtils

extension PredicateMediaList {
    // MARK: Favorites
    static let favorites = PredicateMediaList(
        name: Strings.Lists.defaultListNameFavorites,
        iconName: "heart.fill",
        predicate: NSPredicate(format: "isFavorite = TRUE")
    )
    
    // MARK: Watchlist
    static let watchlist = PredicateMediaList(
        name: Strings.Lists.defaultListNameWatchlist,
        iconName: "bookmark.fill",
        predicate: NSPredicate(format: "isOnWatchlist = TRUE")
    )
    
    // MARK: Problems
    static let problems = PredicateMediaList(
        name: Strings.Lists.defaultListNameProblems,
        iconName: "exclamationmark.triangle.fill",
        // This predicate looks for movies or shows that are incomplete / have problems
        predicate: NSCompoundPredicate(type: .and, subpredicates: [
            // To be included, the movie/show must not be marked as "not watched"
            NSCompoundPredicate(type: .or, subpredicates: [
                // We don't include movies that are marked as 'not watched'
                // type == .movie && (watched == nil || watched != .notWatched)
                NSPredicate(
                    format: "%K = %@ AND (%K = nil OR %K != %@)",
                    Schema.Media.type.rawValue,
                    MediaType.movie.rawValue,
                    Schema.Movie.watchedState.rawValue,
                    Schema.Movie.watchedState.rawValue,
                    MovieWatchState.notWatched.rawValue
                ),
                // We don't include shows that are marked as explicitly 'not watched'
                // type == .show && !(show.notWatched)
                NSCompoundPredicate(type: .and, subpredicates: [
                    NSPredicate(format: "type = %@", MediaType.show.rawValue),
                    ShowWatchState.showsNotWatchedPredicate.negated(),
                ]),
            ]),
            // If any of these applies, information is missing
            NSCompoundPredicate(type: .or, subpredicates: [
                // Personal Rating missing
                NSPredicate(
                    // personalRating == nil || personalRating == .noRating
                    format: "%K = nil OR %K = %lld",
                    Schema.Media.personalRating.rawValue,
                    Schema.Media.personalRating.rawValue,
                    StarRating.noRating.rawValue
                ),
                // WatchAgain missing
                NSPredicate(format: "watchAgain = nil"),
                // Tags missing
                NSPredicate(format: "tags.@count = 0"),
                // Watched missing (Movie)
                NSPredicate(format: "type = %@ AND watchedState = nil", MediaType.movie.rawValue),
                // Last watched missing (Show)
                ShowWatchState.showsWatchedUnknownPredicate,
            ]),
        ])
    )
    
    // MARK: New Seasons
    static let newSeasons = PredicateMediaList(
        name: Strings.Lists.defaultListNameNewSeasons,
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
            NSPredicate(format: "lastSeasonWatched < numberOfSeasons"), // conservative approximation
            
            // Don't include shows marked as "Watch Again?" = false
            NSPredicate(
                format: "%K = %@ OR %K = nil",
                Schema.Media.watchAgain,
                true as NSNumber,
                Schema.Media.watchAgain
            ),
        ]),
        filter: { media in
            if
                let show = media as? Show,
                let latestNonEmptySeasonNumber = show.latestNonEmptySeasonNumber,
                let watched = show.watched
            {
                // Only include shows where the latestNonEmptySeasonNumber has not been watched yet
                return watched < ShowWatchState.season(latestNonEmptySeasonNumber)
            }
            // Results that are not shows or have missing data are not filtered out
            return true
        }
    )
}
