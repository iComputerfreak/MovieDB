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
    
    struct EpisodeNumber: Codable, Hashable {
        var season: Int
        var episode: Int?
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
