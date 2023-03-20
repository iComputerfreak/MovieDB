//
//  PredicateMediaLists.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

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
                NSPredicate(
                    format: "%K = %@ AND (%K = nil OR %K != %@)",
                    Schema.Media.type.rawValue,
                    MediaType.movie.rawValue,
                    Schema.Movie.watchedState.rawValue,
                    Schema.Movie.watchedState.rawValue,
                    MovieWatchState.notWatched.rawValue
                ),
                // We don't include shows that are marked as explicitly 'not watched'
                NSCompoundPredicate(type: .and, subpredicates: [
                    NSPredicate(format: "type = %@", MediaType.show.rawValue),
                    ShowWatchState.showsNotWatchedPredicate.negated(),
                ]),
            ]),
            // If any of these applies, information is missing
            NSCompoundPredicate(type: .or, subpredicates: [
                // Personal Rating missing
                NSPredicate(
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
            ShowWatchState.showsWatchedAnyPredicate,
            NSPredicate(format: "lastSeasonWatched < numberOfSeasons"),
        ])
    )
}
