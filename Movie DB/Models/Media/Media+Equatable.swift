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
            // TMDB Data
            tmdbID == other.tmdbID &&
            title == other.title &&
            originalTitle == other.originalTitle &&
            imagePath == other.imagePath &&
            genres == other.genres &&
            overview == other.overview &&
            status == other.status &&
            originalLanguage == other.originalLanguage &&
            productionCompanies == other.productionCompanies &&
            homepageURL == other.homepageURL &&
            popularity == other.popularity &&
            voteAverage == other.voteAverage &&
            voteCount == other.voteCount &&
            cast == other.cast &&
            keywords == other.keywords &&
            translations == other.translations &&
            videos == other.videos
    }
}

extension Movie {
    override fileprivate func isEqual(to other: Any) -> Bool {
        let other = other as! Movie
        return
            watched == other.watched &&
            releaseDate == other.releaseDate &&
            runtime == other.runtime &&
            budget == other.budget &&
            revenue == other.revenue &&
            tagline == other.tagline &&
            isAdult == other.isAdult &&
            imdbID == other.imdbID &&
            super.isEqual(to: other)
    }
}

extension Show {
    override fileprivate func isEqual(to other: Any) -> Bool {
        let other = other as! Show
        return
            lastEpisodeWatched == other.lastEpisodeWatched &&
            firstAirDate == other.firstAirDate &&
            lastAirDate == other.lastAirDate &&
            numberOfSeasons == other.numberOfSeasons &&
            numberOfEpisodes == other.numberOfEpisodes &&
            episodeRuntime == other.episodeRuntime &&
            isInProduction == other.isInProduction &&
            seasons == other.seasons &&
            type == other.type &&
            networks == other.networks &&
            super.isEqual(to: other)
    }
}
