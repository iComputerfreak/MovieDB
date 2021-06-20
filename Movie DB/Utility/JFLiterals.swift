//
//  JFLiterals.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct JFLiterals {
    /// Size multiplier for the size of the thumbnail in the `MediaDetail` view
    private static let _multiplier: CGFloat = 2.0
    /// The size of the thumbnail in the `LibraryHome` list
    static let thumbnailSize: CGSize = .init(width: 80.0 / 1.5, height: 80.0)
    /// The size of the thumbnail in the `MediaDetail` view
    static let detailPosterSize: CGSize = .init(width: JFLiterals.thumbnailSize.width * _multiplier, height: JFLiterals.thumbnailSize.height * _multiplier)
    /// The name of the poster placeholder image
    static let posterPlaceholderName = "PosterPlaceholder"
    /// The type property of trailer videos
    static let kTrailerVideoType = "Trailer"
    /// The maximum amount of pages to load when searching for media
    static let maxSearchPages = 10
    /// The maximum number of media objects a user can add to his library while not having purchased a pro subscription
    static let nonProMediaLimit = 25
    /// The list of IAP IDs
    static let inAppPurchaseIDs = [inAppPurchaseIDPro]
    /// The IAP ID for the Pro version of the app
    static let inAppPurchaseIDPro = "movie_db_pro"
    
    struct Keys {
        /// The key used for storing the TagLibrary
        static let allTags = "allTags"
        /// The key used for storing the MediaLibrary
        static let mediaLibrary = "mediaLibrary"
        /// The key used for storing all available languages for TheMovieDB.org
        static let tmdbLanguages = "tmdbLanguages"
        /// The version the app was last migrated to
        static let migrationKey = "migrationVersion"
        /// The attribute after which to sort the media objects
        static let sortingOrder = "sortingOrder"
        /// The direction in which to sort the media objects (ascending or descending)
        static let sortingDirection = "sortingDirection"
        /// The paths of posters that have been blacklisted
        static let posterBlacklist = "posterBlacklist"
        /// The time in seconds since 1970 (``Date.timeIntervalSince1970``) when the poster blacklist has last been updated
        static let posterBlacklistLastUpdated = "posterBlacklistLastUpdated"
    }
}
