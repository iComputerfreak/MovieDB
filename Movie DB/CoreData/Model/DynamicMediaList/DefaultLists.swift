//
//  DefaultLists.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

extension DefaultMediaList {
    // MARK: Favorites
    static let favorites = DefaultMediaList(
        name: Strings.Lists.defaultListNameFavorites,
        iconName: "heart.fill",
        predicate: NSPredicate(format: "isFavorite = TRUE")
    )
    
    // MARK: Watchlist
    static let watchlist = DefaultMediaList(
        name: Strings.Lists.defaultListNameWatchlist,
        iconName: "bookmark.fill",
        predicate: NSPredicate(format: "isOnWatchlist = TRUE")
    )
    
    // MARK: Problems
    static let problems = DefaultMediaList(
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
                // We include all shows since the default value for lastSeasonWatched is already "No"
                // TODO: Does not work
                NSPredicate(
                    format: "type = %@ AND (showWatchState = nil OR showWatchState != %@)",
                    MediaType.show.rawValue,
                    ShowWatchState.notWatched.rawValue
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
                    format: "type = %@ AND showWatchState = nil",
                    MediaType.show.rawValue
                ),
            ]),
        ])
    )
}
