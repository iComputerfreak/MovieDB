//
//  TMDBShowData.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit

class TMDBShowData: TMDBData {
    /// The date, the show was first aired
    var firstAirDate: Date?
    /// The date, the show was last aired
    var lastAirDate: Date?
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
    
    init(id: Int, title: String, originalTitle: String, imagePath: String?, genres: [Genre], overview: String?, status: MediaStatus, originalLanguage: String, imdbID: String?, productionCompanies: [ProductionCompany], homepageURL: String?, popularity: Float, voteAverage: Float, voteCount: Int, firstAirDate: Date?, lastAirDate: Date?, numberOfSeasons: Int?, numberOfEpisodes: Int, episodeRuntime: [Int], isInProduction: Bool, seasons: [Season], type: ShowType?, networks: [ProductionCompany]) {
        self.firstAirDate = firstAirDate
        self.lastAirDate = lastAirDate
        self.numberOfSeasons = numberOfSeasons
        self.numberOfEpisodes = numberOfEpisodes
        self.episodeRuntime = episodeRuntime
        self.isInProduction = isInProduction
        self.seasons = seasons
        self.type = type
        self.networks = networks
        super.init(id: id, title: title, originalTitle: originalTitle, imagePath: imagePath, genres: genres, overview: overview, status: status, originalLanguage: originalLanguage, imdbID: imdbID, productionCompanies: productionCompanies, homepageURL: homepageURL, popularity: popularity, voteAverage: voteAverage, voteCount: voteCount)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // If the decoded raw date is nil, we use "" to produce a nil date in the line below
        let rawFirstAirDate = try container.decode(String?.self, forKey: .firstAirDate) ?? ""
        self.firstAirDate = JFUtils.tmdbDateFormatter.date(from: rawFirstAirDate)
        
        let rawLastAirDate = try container.decode(String?.self, forKey: .lastAirDate) ?? ""
        self.lastAirDate = JFUtils.tmdbDateFormatter.date(from: rawLastAirDate)
        
        self.numberOfSeasons = try container.decode(Int?.self, forKey: .numberOfSeasons)
        self.numberOfEpisodes = try container.decode(Int.self, forKey: .numberOfEpisodes)
        self.episodeRuntime = try container.decode([Int].self, forKey: .episodeRuntime)
        self.isInProduction = try container.decode(Bool.self, forKey: .isInProduction)
        self.seasons = try container.decode([Season].self, forKey: .seasons)
        self.type = try container.decode(ShowType?.self, forKey: .type)
        self.networks = try container.decode([ProductionCompany].self, forKey: .networks)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        // Encode the dates using the tmdbDateFormatter, so init reads them correctly again
        var rawFirstAirDate: String? = nil
        var rawLastAirDate: String? = nil
        if let firstAirDate = firstAirDate {
            rawFirstAirDate = JFUtils.tmdbDateFormatter.string(from: firstAirDate)
        }
        if let lastAirDate = lastAirDate {
            rawLastAirDate = JFUtils.tmdbDateFormatter.string(from: lastAirDate)
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawFirstAirDate, forKey: .firstAirDate)
        try container.encode(rawLastAirDate, forKey: .lastAirDate)
        try container.encode(numberOfSeasons, forKey: .numberOfSeasons)
        try container.encode(numberOfEpisodes, forKey: .numberOfEpisodes)
        try container.encode(episodeRuntime, forKey: .episodeRuntime)
        try container.encode(isInProduction, forKey: .isInProduction)
        try container.encode(seasons, forKey: .seasons)
        try container.encode(type, forKey: .type)
        try container.encode(networks, forKey: .networks)
    }
    
    enum CodingKeys: String, CodingKey {
        case firstAirDate = "first_air_date"
        case lastAirDate = "last_air_date"
        case numberOfSeasons = "number_of_seasons"
        case numberOfEpisodes = "number_of_episodes"
        case episodeRuntime = "episode_run_time"
        case isInProduction = "in_production"
        case seasons
        case type
        case networks
    }
    
    // MARK: - Hashable Conformance
    
    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(firstAirDate)
        hasher.combine(lastAirDate)
        hasher.combine(numberOfSeasons)
        hasher.combine(numberOfEpisodes)
        hasher.combine(episodeRuntime)
        hasher.combine(isInProduction)
        hasher.combine(seasons)
        hasher.combine(type)
        hasher.combine(networks)
    }
}
