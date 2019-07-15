//
//  TMDBShowData.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

struct TMDBShowData: TMDBData, Equatable {
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
    
    var castWrapper: CastWrapper?
    var keywordsWrapper: KeywordsWrapper?
    var translationsWrapper: TranslationsWrapper?
    var videosWrapper: VideosWrapper?
    
    // Exclusive properties
    /// The raw first air date formatted as "yyyy-MM-dd"
    var rawFirstAirDate: String
    /// The date, the show was first aired
    var firstAirDate: Date? { JFUtils.dateFromTMDBString(self.rawFirstAirDate) }
    /// The raw last air date formatted as "yyyy-MM-dd"
    var rawLastAirDate: String
    /// The date, the show was last aired
    var lastAirDate: Date? { JFUtils.dateFromTMDBString(self.rawLastAirDate) }
    /// The number of seasons the show  has
    var numberOfSeasons: Int
    /// The number of episodes, the show has
    var numberOfEpisodes: Int
    /// The runtime the episodes typically have
    var episodeRuntime: [Int]
    /// Whether the show is still in production
    var isInProduction: Bool
    /// The list of seasons the show has
    var seasons: [Season]
    /// The type of the show (e.g. Scripted)
    var type: String
    /// The list of networks that publish the show
    var networks: [ProductionCompany]
    
    enum CodingKeys: String, CodingKey {
        // Protocol Properties
        case id
        case title = "name"
        case originalTitle = "original_name"
        case imagePath = "poster_path"
        case genres = "genres"
        case overview
        case status
        case originalLanguage = "original_language"
        case imdbID = "imdb_id"
        case productionCompanies = "production_companies"
        case homepageURL = "homepage"
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        
        // Exclusive Properties
        case rawFirstAirDate = "first_air_date"
        case rawLastAirDate = "last_air_date"
        case numberOfSeasons = "number_of_seasons"
        case numberOfEpisodes = "number_of_episodes"
        case episodeRuntime = "episode_run_time"
        case isInProduction = "in_production"
        case seasons
        case type
        case networks
        
        // Filled externally by separate API calls
        //case keywordsWrapper, castWrapper, translationsWrapper, videosWrapper
    }
}


// MARK: - Property Structs

/// Represents a season of a show
struct Season: Codable, Equatable {
    /// The id of the season on TMDB
    var id: Int
    /// The number of the season
    var seasonNumber: Int
    /// The number of episodes, this season has
    var episodeCount: Int
    /// The name of the season
    var name: String
    /// A short description of the season
    var overview: String?
    /// A path to the poster image of the season on TMDB
    var imagePath: String?
    /// The date when the season aired
    var rawAirDate: String
    /// The date, the season aired
    var airDate: Date? { JFUtils.dateFromTMDBString(self.rawAirDate) }
    
    enum CodingKeys: String, CodingKey {
        case id
        case seasonNumber = "season_number"
        case episodeCount = "episode_count"
        case name
        case overview
        case imagePath = "poster_path"
        case rawAirDate = "air_date"
    } 
}
