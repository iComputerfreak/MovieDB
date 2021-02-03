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
    
    /// Represents an episode of a show
    struct EpisodeNumber: Codable, Hashable, LosslessStringConvertible {
        /// The season number of the episode
        var season: Int
        /// The episode number
        var episode: Int?
        
        /// Creates a new `EpisodeNumber` object
        /// - Parameters:
        ///   - season: The season number
        ///   - episode: The episode number
        init(season: Int, episode: Int? = nil) {
            self.season = season
            self.episode = episode
        }
        
        // MARK: - LosslessStringConvertible Conformance
        
        var description: String { episode == nil ? "\(season)" : "\(season)/\(episode!)" }
        
        /// Instantiates an instance of the conforming type from a string
        /// representation.
        init?(_ description: String) {
            let parts = description.components(separatedBy: "/")
            guard parts.count == 1 || parts.count == 2 else {
                // Too few/many parts
                return nil
            }
            guard let season = Int(parts.first!) else {
                // Season is not a number
                return nil
            }
            self.season = season
            
            if parts.count == 2 {
                guard let episode = Int(parts.last!) else {
                    // Episode is not a number
                    return nil
                }
                self.episode = episode
            } else {
                self.episode = nil
            }
        }
        
        
    }
    
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
    
    /// Creates a new `Show` object.
    init() {
        super.init(type: .show)
    }
    
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Show.CodingKeys.self)
        self.lastEpisodeWatched = try container.decode(EpisodeNumber?.self, forKey: .lastEpisodeWatched)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.lastEpisodeWatched, forKey: .lastEpisodeWatched)
    }
    
    private enum CodingKeys: CodingKey {
        case lastEpisodeWatched
    }
    
    // MARK: - Hashable Conformance
    
    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(lastEpisodeWatched)
    }
}
