//
//  Movie.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

class Movie: Media {
        
    /// Whether the user has watched the media (partly or fully)
    @Published var watched: Bool? = nil {
        didSet {
            if watched == nil {
                self.missingInformation.insert(.watched)
            } else {
                self.missingInformation.remove(.watched)
            }
        }
    }
    
    /// Creates a new `Movie` object.
    init() {
        super.init(type: .movie)
    }
    
    /// Creates a new `Movie` object with type `.movie`, ignoring the argument.
    override init(type: MediaType) {
        super.init(type: .movie)
    }
    
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try super.init(from: container.superDecoder())
        self.watched = try container.decode(Bool?.self, forKey: .watched)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: container.superEncoder())
        try container.encode(self.watched, forKey: .watched)
    }
    
    private enum CodingKeys: CodingKey {
        case watched
    }
    
    override func isEqual(to other: Media) -> Bool {
        guard let other = other as? Movie else {
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
            
            watched == other.watched
    }
    
    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(watched)
    }
}
