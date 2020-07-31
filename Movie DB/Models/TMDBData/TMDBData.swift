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
    /// The id of the media on IMDB.com
    var imdbID: String?
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
        self.imdbID = imdbID
        self.productionCompanies = productionCompanies
        self.homepageURL = homepageURL
        self.popularity = popularity
        self.voteAverage = voteAverage
        self.voteCount = voteCount
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
        hasher.combine(imdbID)
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
