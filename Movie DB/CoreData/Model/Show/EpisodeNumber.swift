//
//  EpisodeNumber.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation

/// Represents an episode of a show
public struct EpisodeNumber: Codable, Hashable {
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
}

extension EpisodeNumber: LosslessStringConvertible {
    public var description: String { episode == nil ? "\(season)" : "\(season)/\(episode!)" }
    
    /// Instantiates an instance of the conforming type from a string
    /// representation.
    public init?(_ description: String) {
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
