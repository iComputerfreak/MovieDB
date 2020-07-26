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
    
    /// Creates a new `Show` object with type `.show`, ignoring the argument.
    override init(type: MediaType) {
        super.init(type: .show)
    }
    
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Show.CodingKeys.self)
        try super.init(from: container.superDecoder())
        self.lastEpisodeWatched = try container.decode(EpisodeNumber?.self, forKey: .lastEpisodeWatched)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: container.superEncoder())
        try container.encode(self.lastEpisodeWatched, forKey: .lastEpisodeWatched)
    }
    
    private enum CodingKeys: CodingKey {
        case lastEpisodeWatched
    }
    
    override func isEqual(to other: Media) -> Bool {
        guard let other = other as? Show else {
            return false
        }
        return
            id == other.id &&
            // TODO: lhs.tmdbData == rhs.tmdbData &&
            type == other.type &&
            personalRating == other.personalRating &&
            tags == other.tags &&
            watchAgain == other.watchAgain &&
            notes == other.notes &&
            thumbnail == other.thumbnail &&
            cast == other.cast &&
            keywords == other.keywords &&
            translations == other.translations &&
            videos == other.videos &&
            year == other.year &&
            missingInformation == other.missingInformation &&
            
            lastEpisodeWatched == other.lastEpisodeWatched
    }
    
    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(lastEpisodeWatched)
    }
}
