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
        description: Strings.Lists.favoritesDescription,
        iconName: "heart.fill",
        predicate: NSPredicate(
            format: "%K = %@",
            Schema.Media.isFavorite,
            true as NSNumber
        )
    )
    
    // MARK: Watchlist
    static let watchlist = PredicateMediaList(
        name: Strings.Lists.defaultListNameWatchlist,
        description: Strings.Lists.watchlistDescription,
        iconName: "bookmark.fill",
        predicate: NSPredicate(
            format: "%K = %@",
            Schema.Media.isOnWatchlist,
            true as NSNumber
        )
    )
    
    // More lists in separate files
}
