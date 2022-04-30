//
//  ShowData.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

extension TMDBData {
    struct ShowData: Decodable, Hashable {
        var rawFirstAirDate: String
        var firstAirDate: Date? {
            Utils.tmdbDateFormatter.date(from: rawFirstAirDate)
        }
        var rawLastAirDate: String
        var lastAirDate: Date? {
            Utils.tmdbDateFormatter.date(from: rawLastAirDate)
        }
        var lastEpisodeToAir: Episode?
        var nextEpisodeToAir: Episode?
        var numberOfSeasons: Int?
        var numberOfEpisodes: Int
        var episodeRuntime: [Int]
        var isInProduction: Bool
        var seasons: [Season]
        var showType: ShowType?
        var networks: [ProductionCompany]
        var createdBy: [String]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.rawFirstAirDate = try container.decode(String.self, forKey: .rawFirstAirDate)
            self.rawLastAirDate = try container.decode(String.self, forKey: .rawLastAirDate)
            self.numberOfSeasons = try container.decode(Int?.self, forKey: .numberOfSeasons)
            self.numberOfEpisodes = try container.decode(Int.self, forKey: .numberOfEpisodes)
            self.episodeRuntime = try container.decode([Int].self, forKey: .episodeRuntime)
            self.isInProduction = try container.decode(Bool.self, forKey: .isInProduction)
            self.seasons = try container.decode([Season].self, forKey: .seasons)
            self.showType = try container.decode(ShowType?.self, forKey: .showType)
            self.networks = try container.decode([ProductionCompany].self, forKey: .networks)
            // created_by
            let creators = try container.decode([Creator].self, forKey: .createdBy)
            self.createdBy = creators.map(\.name)
            self.nextEpisodeToAir = try container.decode(Episode?.self, forKey: .nextEpisodeToAir)
            self.lastEpisodeToAir = try container.decode(Episode?.self, forKey: .lastEpisodeToAir)
        }
        
        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case rawFirstAirDate = "first_air_date"
            case rawLastAirDate = "last_air_date"
            case numberOfSeasons = "number_of_seasons"
            case numberOfEpisodes = "number_of_episodes"
            case episodeRuntime = "episode_run_time"
            case isInProduction = "in_production"
            case seasons
            case showType = "type"
            case networks
            case createdBy = "created_by"
            case nextEpisodeToAir = "next_episode_to_air"
            case lastEpisodeToAir = "last_episode_to_air"
        }
    }
}
