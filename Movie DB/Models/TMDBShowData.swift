//
//  TMDBShowData.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

struct TMDBShowData: TMDBData {
    // Protocol properties
    var id: Int
    var title: String
    var originalTitle: String
    var imagePath: String?
    var genres: [Genre]
    var overview: String?
    var status: String
    var originalLanguage: String
    var imdbID: String?
    var productionCompanies: [ProductionCompany]
    var homepageURL: String?
    var popularity: Float
    var voteAverage: Float
    var voteCount: Int
    
    var castWrapper: CastWrapper
    var keywordsWrapper: KeywordsWrapper
    var translationsWrapper: TranslationsWrapper
    var videosWrapper: VideosWrapper
    
    // Exclusive properties
    /// The date when the show was first aired
    var firstAired: Date
    /// The date when the show was last aired
    var lastAired: Date
    /// The number of seasons the show  has
    var numberOfSeasons: Int
    /// The number of episodes, each season has
    var numberOfEpisodes: [Int: Int]
    /// The runtime the episodes typically have
    var episodeRuntime: [Int]
    /// Whether the show is still in production
    var isInProduction: Bool
    /// The list of seasons the show has
    var seasons: [Season]
    /// The type of the show (e.g. Scripted)
    var type: String
    
    enum CodingKeys: String, CodingKey {
        // Protocol Properties
        case id
        case title
        case originalTitle
        case imagePath
        case genres
        case overview
        case status
        case originalLanguage
        case imdbID
        case productionCompanies
        case homepageURL
        case popularity
        case voteAverage
        case voteCount
        
        // Exclusive Properties
        case firstAired = "first_air_date"
        case lastAired = "last_air_date"
        case numberOfSeasons = "number_of_seasons"
        case numberOfEpisodes = "number_of_episodes"
        case episodeRuntime = "episode_run_time"
        case isInProduction = "in_production"
        case seasons
        case type
        
        // Filled externally by separate API calls
        case keywordsWrapper, castWrapper, translationsWrapper, videosWrapper
    }
}


// MARK: - Property Structs

/// Represents a season of a show
struct Season: Codable {
    /// The id of the season on TMDB
    var id: Int
    /// The number of the season
    var seasonNumber: Int
    /// The number of episodes, this season has
    var episodeCount: Int
    /// The name of the season
    var name: String
    /// A short description of the season
    var overview: String
    /// A path to the poster image of the season on TMDB
    var imagePath: String
    /// The date, the season aired
    var airDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case seasonNumber = "season_number"
        case episodeCount = "episode_count"
        case name
        case overview
        case imagePath = "poster_path"
        case airDate = "air_date"
    } 
}
