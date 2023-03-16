//
//  CSVKey.swift
//  Movie DB
//
//  Created by Jonas Frey on 16.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation

enum CSVKey: String, CaseIterable {
    // Import
    case tmdbID = "tmdb_id"
    case mediaType = "type"
    case personalRating = "personal_rating"
    case watchAgain = "watch_again"
    case tags
    case notes
    // Movie exclusive
    case movieWatched = "movie_watched"
    // Show exclusive
    case showWatched = "show_watched"
    case lastSeasonWatched = "last_season_watched"
    case lastEpisodeWatched = "last_episode_watched"
    
    // Export only
    case id
    case tagline
    case title
    case originalTitle = "original_title"
    case genres
    case overview
    case status
    case releaseDate = "release_date"
    case runtime
    case budget
    case revenue
    case isAdult = "is_adult"
    case firstAirDate = "first_air_date"
    case lastAirDate = "last_air_date"
    case numberOfSeasons = "number_of_seasons"
    case isInProduction = "is_in_production"
    case showType = "show_type"
    case createdBy = "created_by"
    
    case creationDate = "creation_date"
    case modificationDate = "modification_date"
}
