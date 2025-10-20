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
        subtitleContentUserDefaultsKey: "favoritesSubtitleContent",
        defaultSubtitleContent: .personalRating,
        description: Strings.Lists.favoritesDescription,
        iconName: "heart.fill",
        predicate: NSPredicate(
            format: "%K = %@",
            Schema.Media.isFavorite,
            true as NSNumber
        )
    )
}
