//
//  Show.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit

class Show: Media {
    
    /// The season and episode number of the episode, the user has watched most recently
    @Published var lastEpisodeWatched: EpisodeNumber? {
        didSet {
            if lastEpisodeWatched == nil {
                self.missingInformation.insert(.watched)
            } else {
                self.missingInformation.remove(.watched)
            }
        }
    }
    /// The date, the show was first aired
    @Published var firstAirDate: Date?
    /// The date, the show was last aired
    @Published var lastAirDate: Date?
    /// The number of seasons the show  has
    @Published var numberOfSeasons: Int?
    /// The number of episodes, the show has
    @Published var numberOfEpisodes: Int
    /// The runtime the episodes typically have
    @Published var episodeRuntime: [Int]
    /// Whether the show is still in production
    @Published var isInProduction: Bool
    /// The list of seasons the show has
    @Published var seasons: [Season]
    /// The type of the show (e.g. Scripted)
    @Published var showType: ShowType?
    /// The list of networks that publish the show
    @Published var networks: [ProductionCompany]
    
    /// Creates a new `Show` object.
    init(tmdbData: TMDBData) {
        // This is a show, therefore the TMDBData needs to have show specific data
        let showData = tmdbData.showData!
        self.firstAirDate = showData.firstAirDate
        self.lastAirDate = showData.lastAirDate
        self.numberOfSeasons = showData.numberOfSeasons
        self.numberOfEpisodes = showData.numberOfEpisodes
        self.episodeRuntime = showData.episodeRuntime
        self.isInProduction = showData.isInProduction
        self.seasons = showData.seasons
        self.showType = showData.showType
        self.networks = showData.networks
        super.init(type: .show, tmdbData: tmdbData)
    }
    
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Show.CodingKeys.self)
        self.lastEpisodeWatched = try container.decode(EpisodeNumber?.self, forKey: .lastEpisodeWatched)
        self.firstAirDate = try container.decode(Date?.self, forKey: .firstAirDate)
        self.lastAirDate = try container.decode(Date?.self, forKey: .lastAirDate)
        self.numberOfSeasons = try container.decode(Int?.self, forKey: .numberOfSeasons)
        self.numberOfEpisodes = try container.decode(Int.self, forKey: .numberOfEpisodes)
        self.episodeRuntime = try container.decode([Int].self, forKey: .episodeRuntime)
        self.isInProduction = try container.decode(Bool.self, forKey: .isInProduction)
        self.seasons = try container.decode([Season].self, forKey: .seasons)
        self.showType = try container.decode(ShowType?.self, forKey: .showType)
        self.networks = try container.decode([ProductionCompany].self, forKey: .networks)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lastEpisodeWatched, forKey: .lastEpisodeWatched)
        try container.encode(firstAirDate, forKey: .firstAirDate)
        try container.encode(lastAirDate, forKey: .lastAirDate)
        try container.encode(numberOfSeasons, forKey: .numberOfSeasons)
        try container.encode(numberOfEpisodes, forKey: .numberOfEpisodes)
        try container.encode(episodeRuntime, forKey: .episodeRuntime)
        try container.encode(isInProduction, forKey: .isInProduction)
        try container.encode(seasons, forKey: .seasons)
        try container.encode(showType, forKey: .showType)
        try container.encode(networks, forKey: .networks)
    }
    
    private enum CodingKeys: CodingKey {
        case lastEpisodeWatched
        case firstAirDate
        case lastAirDate
        case numberOfSeasons
        case numberOfEpisodes
        case episodeRuntime
        case isInProduction
        case seasons
        case showType
        case networks
    }
    
    // MARK: - Hashable Conformance
    
    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(lastEpisodeWatched)
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
