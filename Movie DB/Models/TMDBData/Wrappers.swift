//
//  Wrappers.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

/// Represents a set of credits info containing the cast members
/// Only the cast members will be decoded/encoded. Other values will be ignored
struct CastWrapper: Codable, Equatable {
    var cast: [CastMember]
    
    enum CodingKeys: String, CodingKey {
        case cast
    }
    
    /// Creates a new CreditsInfo from the data of the given decoder.
    /// Only the cast will be encoded
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cast = try container.decode([CastMember].self, forKey: .cast)
    }
    
    /// Encodes this CreditsInfo to an encoder.
    /// Only the cast will be encoded
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.cast, forKey: .cast)
    }
}

/// Represents a wrapper containing a single keyword
struct KeywordWrapper: Codable, Equatable {
    // ID is not used, but still decoded (simpler than overriding De-/Encodable)
    /// The ID of the keyword
    var id: Int
    /// The keyword
    var name: String
}

/// Represents a wrapper containing the keywords
/// Only the keywords will be decoded/encoded. Other values will be ignored
struct KeywordsWrapper: Codable, Equatable {
    var keywords: [KeywordWrapper]
    
    enum CodingKeys: String, CodingKey {
        case keywords
    }
    
    /// Creates new keywords from the data of the given decoder.
    /// Only the keywords will be encoded
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keywords = try container.decode([KeywordWrapper].self, forKey: .keywords)
    }
    
    /// Encodes the keywords to an encoder.
    /// Only the keywords will be encoded
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.keywords, forKey: .keywords)
    }
}

/// Represents a wrapper containing a list of translation wrappers
struct TranslationsWrapper: Codable, Equatable {
    // ID is not used, but still decoded (simpler than overriding De-/Encodable)
    /// The ID of the translations list
    var id: Int
    /// The list of translation wrappers containing the translation names
    var translations: [TranslationWrapper]
}

/// Represents a wrapper containing a translation
/// Only the keywords will be decoded/encoded. Other values will be ignored
struct TranslationWrapper: Codable, Equatable {
    /// The localized name of the language
    var name: String
    /// The english name of the language
    var englishName: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case englishName = "english_name"
    }
    
    /// Creates a new name and english name from the data of the given decoder.
    /// Only the name and english name will be encoded
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.englishName = try container.decode(String.self, forKey: .englishName)
    }
    
    /// Encodes the name and english name to an encoder.
    /// Only the name and english name will be encoded
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.englishName, forKey: .englishName)
    }
}

/// Represents a wrapper containing a list of Videos
struct VideosWrapper: Codable, Equatable {
    // ID is not used, but still decoded (simpler than overriding De-/Encodable)
    /// The ID of the result
    var id: Int
    /// The list of videos
    var videos: [Video]
    
    enum CodingKeys: String, CodingKey {
        case id
        case videos = "results"
    }
}
