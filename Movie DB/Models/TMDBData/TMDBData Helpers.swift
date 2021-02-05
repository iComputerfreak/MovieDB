//
//  TMDBData Helpers.swift
//  Movie DB
//
//  Created by Jonas Frey on 31.07.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData

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


/// Represents a Media genre
struct Genre: Codable, Equatable, Hashable, LosslessStringConvertible {
    /// The ID of the genre on TMDB
    let id: Int
    /// The name of the genre
    let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    // MARK: - LosslessStringConvertible Conformance
    
    var description: String {
        return "\(name)(\(id))"
    }
    
    init?(_ description: String) {
        guard description.hasSuffix(")") else {
            return nil
        }
        let description = description.removingSuffix(")")
        let components = description.components(separatedBy: "(")
        guard components.count == 2 else {
            return nil
        }
        self.name = components.first!
        guard let id = Int(components.last!) else {
            return nil
        }
        self.id = id
    }
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
