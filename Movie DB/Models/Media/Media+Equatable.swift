//
//  Media+Equatable.swift
//  Movie DB
//
//  Created by Jonas Frey on 31.07.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

extension Media: Equatable {
    
    static func == (lhs: Media, rhs: Media) -> Bool {
        guard Swift.type(of: lhs) == Swift.type(of: rhs) else { return false }
        return lhs.isEqual(to: rhs)
    }
    
    // The static `==` function only calls this, after confirming, that other and self have the same type.
    // Subclasses are also calling this, but the `other as! TMDBData` statement also works, if other is a subclass of TMDBData
    @objc fileprivate func isEqual(to other: Any) -> Bool {
        let other = other as! Media
        return
            id == other.id &&
            type == other.type &&
            personalRating == other.personalRating &&
            tags == other.tags &&
            watchAgain == other.watchAgain &&
            notes == other.notes &&
            thumbnail == other.thumbnail &&
            year == other.year &&
            missingInformation == other.missingInformation &&
            tmdbData == other.tmdbData
    }
}

extension Movie {
    override fileprivate func isEqual(to other: Any) -> Bool {
        let other = other as! Movie
        return
            watched == other.watched &&
            super.isEqual(to: other)
    }
}

extension Show {
    override fileprivate func isEqual(to other: Any) -> Bool {
        let other = other as! Show
        return
            lastEpisodeWatched == other.lastEpisodeWatched &&
            super.isEqual(to: other)
    }
}
