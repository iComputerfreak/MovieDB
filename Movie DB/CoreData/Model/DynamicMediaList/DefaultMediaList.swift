//
//  DefaultMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

class DefaultMediaList: MediaListProtocol {
    let name: String
    let iconName: String
    let predicate: NSPredicate
    
    var sortingOrder: SortingOrder {
        didSet {
            let key = Self.userDefaultsKey(for: name, type: .sortingOrder)
            UserDefaults.standard.set(sortingOrder.rawValue, forKey: key)
        }
    }

    var sortingDirection: SortingDirection {
        didSet {
            let key = Self.userDefaultsKey(for: name, type: .sortingDirection)
            UserDefaults.standard.set(sortingDirection.rawValue, forKey: key)
        }
    }
    
    init(name: String, iconName: String, predicate: NSPredicate) {
        self.name = name
        self.iconName = iconName
        self.predicate = predicate
        // We know that the name is unique, because we only have a predefined set of names
        let orderKey = Self.userDefaultsKey(for: name, type: .sortingOrder)
        if
            let sortingOrderRawValue = UserDefaults.standard.string(forKey: orderKey),
            let order = SortingOrder(rawValue: sortingOrderRawValue)
        {
            sortingOrder = order
        } else {
            sortingOrder = .default
        }
        
        let directionKey = Self.userDefaultsKey(for: name, type: .sortingDirection)
        if
            let sortingDirectionRawValue = UserDefaults.standard.string(forKey: directionKey),
            let direction = SortingDirection(rawValue: sortingDirectionRawValue)
        {
            sortingDirection = direction
        } else {
            sortingDirection = sortingOrder.defaultDirection
        }
    }
    
    private static func userDefaultsKey(for name: String, type: StorageType) -> String {
        "defaultList_\(type.rawValue)_\(name)"
    }
    
    func buildFetchRequest() -> NSFetchRequest<Media> {
        let fetch = Media.fetchRequest()
        fetch.predicate = predicate
        fetch.sortDescriptors = sortingOrder.createSortDescriptors(with: sortingDirection)
        return fetch
    }
    
    private enum StorageType: String {
        case sortingOrder
        case sortingDirection
    }
}

extension DefaultMediaList {
    static let favorites = DefaultMediaList(
        name: Strings.Lists.defaultListNameFavorites,
        iconName: "heart.fill",
        predicate: NSPredicate(format: "isFavorite = TRUE")
    )
    
    static let watchlist = DefaultMediaList(
        name: Strings.Lists.defaultListNameWatchlist,
        iconName: "bookmark.fill",
        predicate: NSPredicate(format: "isOnWatchlist = TRUE")
    )
    
    static let problems = DefaultMediaList(
        name: Strings.Lists.defaultListNameProblems,
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
