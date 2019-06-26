//
//  TMDBData.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit

// MARK: TMDB Data

/// Represents a set of data about the media from themoviedb.org
protocol TMDBData: Codable, Equatable {
    // Basic Data
    var id: Int { get set }
    /// The name of the media
    var title: String { get set }
    /// The original tile of the media
    var originalTitle: String { get set }
    /// The path of the media poster image on TMDB
    var imagePath: String? { get set }
    /// A list of genres that match the media
    var genres: [Genre] { get set }
    /// A short media description
    var overview: String? { get set }
    /// The status of the media (e.g. Rumored, Planned, In Production, Post Production, Released, Canceled)
    var status: String { get set }
    
    // Extended Data
    /// The language the movie was originally created in as an ISO-639-1 string (e.g. 'en')
    var originalLanguage: String { get set }
    /// The id of the media on IMDB.com
    var imdbID: String? { get set }
    /// A list of companies that produced the media
    var productionCompanies: [ProductionCompany] { get set }
    /// The url to the homepage of the media
    var homepageURL: String? { get set }
    
    // TMDB Scoring
    /// The popularity of the media on TMDB
    var popularity: Float { get set }
    /// The average rating on TMDB
    var voteAverage: Float { get set }
    /// The number of votes that were cast on TMDB
    var voteCount: Int { get set }
    
    // Computed Properties
    /// The list of actors
    var cast: [CastMember]? { get }
    /// A list of keywords that match the media
    var keywords: [String]? { get }
    /// A list of languages the media was translated to
    var translations: [String]? { get }
    /// The links to the media trailers
    var trailers: [Video]? { get }
    
    // Codable Helper properties
    /// The wrapper containing the cast
    /// - Important:Use `TMDBData.cast` to access the cast members
    var castWrapper: CastWrapper? { get set }
    /// The wrapper containing the list of keywords
    /// - Important: Use `TMDBData.keywords` to access the keywords
    var keywordsWrapper: KeywordsWrapper? { get set }
    /// The wrapper containing the list of translations
    /// - Important: Use `TMDBData.translations` to access the translations
    var translationsWrapper: TranslationsWrapper? { get set }
    /// The wrapper containing the list of videos
    /// - Important: Use `TMDB.trailers` to access the trailers
    var videosWrapper: VideosWrapper? { get set }
}

/// Implements the computed properties
extension TMDBData {
    var cast: [CastMember]? {
        self.castWrapper?.cast
    }
    var keywords: [String]? {
        self.keywordsWrapper?.keywords.map { $0.name }
    }
    var translations: [String]? {
        self.translationsWrapper?.translations.map { $0.englishName }
    }
    var trailers: [Video]? {
        self.videosWrapper?.videos.filter { $0.type == .trailer }
    }
}

// MARK: - Property Structs

/// Represents an actor starring in a specific movie
struct CastMember: Codable, Equatable {
    /// The name of the actor
    var name: String
    /// The name of the actor in the media
    var roleName: String
    /// The path to an image of the actor on TMDB
    var imagePath: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case roleName = "character"
        case imagePath = "profile_path"
    }
    
    /// Creates a new CastMember from the data of the given decoder.
    /// Only the name, role name and image path will be decoded
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.roleName = try container.decode(String.self, forKey: .roleName)
        self.imagePath = try container.decode(String?.self, forKey: .imagePath)
    }
    
    /// Encodes this CastMember to an encoder.
    /// Only the name, role name and image path will be encoded
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.roleName, forKey: .roleName)
        try container.encode(self.imagePath, forKey: .imagePath)
    }
}

/// Represents a video on some external site
struct Video: Codable, Equatable {
    
    enum VideoType: String, Codable {
        case trailer = "Trailer"
        case teaser = "Teaser"
        case clip = "Clip"
        case featurette = "Featurette"
        case behindTheScenes = "Behind the Scenes"
        case bloopers = "Bloopers"
    }
    
    /// The video key
    var key: String
    /// The name of the video
    var name: String
    /// The site where the video was uploaded to
    var site: String
    /// The type of video (e.g. Trailer)
    var type: VideoType
    /// The resolution of the video
    var resolution: Int
    /// The ISO-639-1 language code  (e.g. 'en')
    var language: String
    /// The ISO-3166-1 country code (e.g. 'US')
    var country: String
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case site
        case type
        case resolution = "size"
        case language = "iso_639_1"
        case country = "iso_3166_1"
    }
}

// MARK: - Codable Helper Structs
/// Represents a Media genre
struct Genre: Codable, Equatable {
    /// The ID of the genre on TMDB
    var id: Int
    /// The name of the genre
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

/// Represents a production company
struct ProductionCompany: Codable, Equatable {
    /// The ID of the production company on TMDB
    var id: Int
    /// The name of the production company
    var name: String
    /// The path to the logo on TMDB
    var logoPath: String?
    /// The country of origin of the production company
    var originCountry: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}

// MARK: - Wrapper Structs

// MARK: Cast

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

// MARK: Keywords

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

/// Represents a wrapper containing a single keyword
struct KeywordWrapper: Codable, Equatable {
    // ID is not used, but still decoded (simpler than overriding De-/Encodable)
    /// The ID of the keyword
    var id: Int
    /// The keyword
    var name: String
}

// MARK: Translations

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

// MARK: Videos

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
