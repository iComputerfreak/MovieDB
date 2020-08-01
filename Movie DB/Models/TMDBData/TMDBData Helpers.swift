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
    let name: String
    /// The name of the actor in the media
    let roleName: String
    /// The path to an image of the actor on TMDB
    let imagePath: String?
    
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
    let key: String
    /// The name of the video
    let name: String
    /// The site where the video was uploaded to
    let site: String
    /// The type of video (e.g. Trailer)
    let type: String
    /// The resolution of the video
    let resolution: Int
    /// The ISO-639-1 language code  (e.g. 'en')
    let language: String
    /// The ISO-3166-1 region code (e.g. 'US')
    let region: String
    
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
    let id: Int
    /// The name of the genre
    let name: String
}

/// Represents a production company
struct ProductionCompany: Codable, Hashable {
    /// The ID of the production company on TMDB
    let id: Int
    /// The name of the production company
    let name: String
    /// The path to the logo on TMDB
    let logoPath: String?
    /// The country of origin of the production company
    let originCountry: String
    
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
