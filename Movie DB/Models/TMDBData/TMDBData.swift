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
protocol TMDBData: Codable {
    // Basic Data
    /// The TMDB ID of the media
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
    var status: MediaStatus { get set }
    /// The language the movie was originally created in as an ISO-639-1 string (e.g. 'en')
    var originalLanguage: String { get set }
    
    // Extended Data
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
}

// MARK: - Property Structs

/// Represents an actor starring in a specific movie
struct CastMember: Codable, Hashable, Equatable, Identifiable {
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

/// Represents the status of a media (e.g. Planned, Rumored, Returning Series, Canceled)
enum MediaStatus: String, Codable {
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
