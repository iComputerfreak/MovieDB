//
//  TMDBShowData.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit

struct TMDBShowData: TMDBData, Equatable {
    // Protocol properties
    var id: Int
    var title: String
    var originalTitle: String
    var imagePath: String?
    var genres: [Genre]
    var overview: String?
    var status: MediaStatus
    var originalLanguage: String
    var imdbID: String?
    var productionCompanies: [ProductionCompany]
    var homepageURL: String?
    var popularity: Float
    var voteAverage: Float
    var voteCount: Int
    
    // Exclusive properties
    /// The raw first air date formatted as "yyyy-MM-dd"
    var rawFirstAirDate: String?
    /// The date, the show was first aired
    var firstAirDate: Date? { rawFirstAirDate == nil ? nil : JFUtils.dateFromTMDBString(self.rawFirstAirDate!) }
    /// The raw last air date formatted as "yyyy-MM-dd"
    var rawLastAirDate: String?
    /// The date, the show was last aired
    var lastAirDate: Date? { rawLastAirDate == nil ? nil : JFUtils.dateFromTMDBString(self.rawLastAirDate!) }
    /// The number of seasons the show  has
    var numberOfSeasons: Int?
    /// The number of episodes, the show has
    var numberOfEpisodes: Int
    /// The runtime the episodes typically have
    var episodeRuntime: [Int]
    /// Whether the show is still in production
    var isInProduction: Bool
    /// The list of seasons the show has
    var seasons: [Season]
    /// The type of the show (e.g. Scripted)
    var type: ShowType?
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
    }
}
