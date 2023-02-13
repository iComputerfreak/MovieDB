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
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                // We don't include movies that are marked as 'not watched'
                NSPredicate(
                    format: "type = %@ AND (watchedState = nil OR watchedState != %@)",
                    MediaType.movie.rawValue,
                    MovieWatchState.notWatched.rawValue
                ),
                // We don't include shows that are marked as explicitly 'not watched'
                NSPredicate(
                    format: "type = %@ AND $showsNotWatched",
                    MediaType.show.rawValue
                ),
            ]),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Personal Rating missing
                NSPredicate(format: "personalRating = nil"),
                // WatchAgain missing
                NSPredicate(format: "watchAgain = nil"),
                // Tags missing
                NSPredicate(format: "tags.@count = 0"),
                // Watched missing (Movie)
                NSPredicate(format: "type = %@ AND watchedState = nil", MediaType.movie.rawValue),
                // LastWatched missing (Show)
                NSPredicate(
                    format: "type = %@ AND $showsWatchedUnknown",
                    MediaType.show.rawValue
                ),
            ]),
        ])
    )
    
    // MARK: New Seasons
//    static let newSeasons = PredicateMediaList(
//        name: Strings.Lists.defaultListNameNewSeasons,
//        iconName: "sparkles.tv",
//        predicate: NSCompoundPredicate(type: .and, subpredicates: [
//            NSPredicate(format: "type = %@", MediaType.show.rawValue),
//            NSPredicate(format: "showWatchState LIKE %@", "season,*"),
//            // TODO: Does not work! We need to store season and episode in separate attributes again
//            NSPredicate(format: "showWatchState ENDSWITH numberOfSeasons"),
//        ])
//    )
}
