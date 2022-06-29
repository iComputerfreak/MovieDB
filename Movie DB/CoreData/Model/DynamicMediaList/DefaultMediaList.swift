//
//  DefaultMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

struct DefaultMediaList: MediaListProtocol {
    let name: String
    let iconName: String
    let predicate: NSPredicate
    
    func buildFetchRequest() -> NSFetchRequest<Media> {
        let fetch = Media.fetchRequest()
        fetch.predicate = predicate
        fetch.sortDescriptors = []
        return fetch
    }
}

extension DefaultMediaList {
    static let favorites = DefaultMediaList(
        name: "Favorites",
        iconName: "star.fill",
        predicate: NSPredicate(format: "isFavorite = TRUE")
    )
    
    static let watchlist = DefaultMediaList(
        name: "Watchlist",
        iconName: "bookmark.fill",
        predicate: NSPredicate(format: "isOnWatchlist = TRUE")
    )
    
    static let problems = DefaultMediaList(
        name: "Problems",
        iconName: "exclamationmark.triangle.fill",
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                // We don't include
                NSPredicate(
                    format: "type = %@ AND watchedState != %@",
                    MediaType.movie.rawValue,
                    MovieWatchState.notWatched.rawValue
                ),
                // We include all shows since the default value for lastSeasonWatched is already "No"
                NSPredicate(
                    format: "type = %@",
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
                    format: "type = %@ AND lastEpisodeWatched = nil AND lastSeasonWatched = nil",
                    MediaType.show.rawValue
                ),
            ]),
        ])
    )
}
