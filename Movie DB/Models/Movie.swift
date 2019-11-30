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
    @Published var watched: Bool? = nil
    
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
    
}
