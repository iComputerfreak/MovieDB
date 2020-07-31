//
//  TMDBData Helpers.swift
//  Movie DB
//
//  Created by Jonas Frey on 31.07.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

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
