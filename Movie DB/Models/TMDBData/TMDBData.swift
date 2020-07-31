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

// TODO: Add videos, translations, keywords and cast to TMDBData directly (and decode it). Requires, that the data is requested using append_to_response=videos,keywords,translations,credits
// Move them from Media here
// TODO: Test, if the structure of Cast, Translations, etc. still is correct

// TODO: Make Hashable
/// Represents a set of data about the media from themoviedb.org
class TMDBData: Codable, Hashable {
    // Basic Data
    /// The TMDB ID of the media
    var id: Int
    /// The name of the media
    var title: String
    /// The original tile of the media
    var originalTitle: String
    /// The path of the media poster image on TMDB
    var imagePath: String?
    /// A list of genres that match the media
    var genres: [Genre]
    /// A short media description
    var overview: String?
    /// The status of the media (e.g. Rumored, Planned, In Production, Post Production, Released, Canceled)
    var status: MediaStatus
    /// The language the movie was originally created in as an ISO-639-1 string (e.g. 'en')
    var originalLanguage: String
    
    // Extended Data
    /// A list of companies that produced the media
    var productionCompanies: [ProductionCompany]
    /// The url to the homepage of the media
    var homepageURL: String?
    
    // TMDB Scoring
    /// The popularity of the media on TMDB
    var popularity: Float
    /// The average rating on TMDB
    var voteAverage: Float
    /// The number of votes that were cast on TMDB
    var voteCount: Int
    
    /// Creates a new TMDBData object
    /// - Important: Never call this initializer directly, always instantiate a concrete subclass!
    init(id: Int, title: String, originalTitle: String, imagePath: String?, genres: [Genre], overview: String?, status: MediaStatus, originalLanguage: String, imdbID: String?, productionCompanies: [ProductionCompany], homepageURL: String?, popularity: Float, voteAverage: Float, voteCount: Int) {
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self.imagePath = imagePath
        self.genres = genres
        self.overview = overview
        self.status = status
        self.originalLanguage = originalLanguage
        self.productionCompanies = productionCompanies
        self.homepageURL = homepageURL
        self.popularity = popularity
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }
    
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decodeAny(String.self, forKeys: [.title, .showTitle])
        self.originalTitle = try container.decodeAny(String.self, forKeys: [.originalTitle, .originalShowTitle])
        self.imagePath = try container.decode(String?.self, forKey: .imagePath)
        self.genres = try container.decode([Genre].self, forKey: .genres)
        self.overview = try container.decode(String?.self, forKey: .overview)
        self.status = try container.decode(MediaStatus.self, forKey: .status)
        self.originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        self.productionCompanies = try container.decode([ProductionCompany].self, forKey: .productionCompanies)
        self.homepageURL = try container.decode(String?.self, forKey: .homepageURL)
        self.popularity = try container.decode(Float.self, forKey: .popularity)
        self.voteAverage = try container.decode(Float.self, forKey: .voteAverage)
        self.voteCount = try container.decode(Int.self, forKey: .voteCount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        // When encoding to disk, we can always use title, never name, because we encode the data only for saving to disk or csv
        // and never return the data to the API
        try container.encode(title, forKey: .title)
        try container.encode(originalTitle, forKey: .originalTitle)
        try container.encode(imagePath, forKey: .imagePath)
        try container.encode(genres, forKey: .genres)
        try container.encode(overview, forKey: .overview)
        try container.encode(status, forKey: .status)
        try container.encode(originalLanguage, forKey: .originalLanguage)
        try container.encode(productionCompanies, forKey: .productionCompanies)
        try container.encode(homepageURL, forKey: .homepageURL)
        try container.encode(popularity, forKey: .popularity)
        try container.encode(voteAverage, forKey: .voteAverage)
        try container.encode(voteCount, forKey: .voteCount)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case showTitle = "name"
        case originalTitle = "original_title"
        case originalShowTitle = "original_name"
        case imagePath = "poster_path"
        case genres = "genres"
        case overview
        case status
        case originalLanguage = "original_language"
        case productionCompanies = "production_companies"
        case homepageURL = "homepage"
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    // MARK: - Hashable Conformance
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(originalTitle)
        hasher.combine(imagePath)
        hasher.combine(genres)
        hasher.combine(overview)
        hasher.combine(status)
        hasher.combine(originalLanguage)
        hasher.combine(productionCompanies)
        hasher.combine(homepageURL)
        hasher.combine(popularity)
        hasher.combine(voteAverage)
        hasher.combine(voteCount)
    }
}

// MARK: - Property Structs

/// Represents an actor starring in a specific movie
struct CastMember: Codable, Hashable, Identifiable {
    let id: Int
    /// The name of the actor
    var name: String
    /// The name of the actor in the media
    var roleName: String
    /// The path to an image of the actor on TMDB
    var imagePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case roleName = "character"
        case imagePath = "profile_path"
    }
}

/// Represents a video on some external site
struct Video: Codable, Hashable {
    
    /// The video key
    var key: String
    /// The name of the video
    var name: String
    /// The site where the video was uploaded to
    var site: String
    /// The type of video (e.g. Trailer)
    var type: String
    /// The resolution of the video
    var resolution: Int
    /// The ISO-639-1 language code  (e.g. 'en')
    var language: String
    /// The ISO-3166-1 region code (e.g. 'US')
    var region: String
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case site
        case type
        case resolution = "size"
        case language = "iso_639_1"
        case region = "iso_3166_1"
    }
}

// MARK: - Codable Helper Structs
/// Represents a Media genre
struct Genre: Codable, Equatable, Hashable {
    /// The ID of the genre on TMDB
    var id: Int
    /// The name of the genre
    var name: String
}

/// Represents a production company
struct ProductionCompany: Codable, Hashable {
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

/// Represents the status of a media (e.g. Planned, Rumored, Returning Series, Canceled)
enum MediaStatus: String, Codable, CaseIterable, Hashable {
    // MARK: General
    case planned = "Planned"
    case inProduction = "In Production"
    case canceled = "Canceled"
    // MARK: Show Exclusive
    case returning = "Returning Series"
    case pilot = "Pilot"
    case ended = "Ended"
    // MARK: Movie Exclusive
    case rumored = "Rumored"
    case postProduction = "Post Production"
    case released = "Released"
}
