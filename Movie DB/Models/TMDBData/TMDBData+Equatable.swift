//
//  TMDBData+Equatable.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.07.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

extension TMDBData: Equatable {
    
    static func == (lhs: TMDBData, rhs: TMDBData) -> Bool {
        guard type(of: lhs) == type(of: rhs) else { return false }
        return lhs.isEqual(to: rhs)
    }
    
    // The static `==` function only calls this, after confirming, that other and self have the same type.
    // Subclasses are also calling this, but the `other as! TMDBData` statement also works, if other is a subclass of TMDBData
    @objc fileprivate func isEqual(to other: Any) -> Bool {
        let other = other as! TMDBData
        return
            id == other.id &&
            title == other.title &&
            originalTitle == other.originalTitle &&
            imagePath == other.imagePath &&
            genres == other.genres &&
            overview == other.overview &&
            status == other.status &&
            originalLanguage == other.originalLanguage &&
            imdbID == other.imdbID &&
            productionCompanies == other.productionCompanies &&
            homepageURL == other.homepageURL &&
            popularity == other.popularity &&
            voteAverage == other.voteAverage &&
            voteCount == other.voteCount
    }
}

extension TMDBMovieData {
    override fileprivate func isEqual(to other: Any) -> Bool {
        let other = other as! TMDBMovieData
        return
            releaseDate == other.releaseDate &&
            runtime == other.runtime &&
            budget == other.budget &&
            revenue == other.revenue &&
            tagline == other.tagline &&
            isAdult == other.isAdult &&
            super.isEqual(to: other)
    }
}

extension TMDBShowData {
    override fileprivate func isEqual(to other: Any) -> Bool {
        let other = other as! TMDBShowData
        return
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
