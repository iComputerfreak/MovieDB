//
//  SearchResult.swift
//  Movie DB
//
//  Created by Jonas Frey on 29.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

protocol TMDBSearchResult: Codable {
    // Basic Data
    /// The TMDB ID of the media
    var id: Int { get set }
    /// The name of the media
    var title: String { get set }
    /// The type of media
    var mediaType: MediaType { get set }
    /// The path of the media poster image on TMDB
    var imagePath: String? { get set }
    /// A short media description
    var overview: String? { get set }
    /// The original tile of the media
    var originalTitle: String { get set }
    /// The language the movie was originally created in as an ISO-639-1 string (e.g. 'en')
    var originalLanguage: String { get set }
    
    // TMDB Scoring
    /// The popularity of the media on TMDB
    var popularity: Float { get set }
    /// The average rating on TMDB
    var voteAverage: Float { get set }
    /// The number of votes that were cast on TMDB
    var voteCount: Int { get set }
    /// Whether the result is a movie and is for adults only
    var isAdultMovie: Bool? { get }
}

// Implementations
extension TMDBSearchResult {
    var isAdultMovie: Bool? { (self as? TMDBMovieSearchResult)?.isAdult }
}

struct TMDBMovieSearchResult: TMDBSearchResult, Identifiable {
    var id: Int
    var title: String
    var mediaType: MediaType
    var imagePath: String?
    var overview: String?
    var originalTitle: String
    var originalLanguage: String
    var popularity: Float
    var voteAverage: Float
    var voteCount: Int
    
    /// Whether the movie is an adult movie
    var isAdult: Bool
    /// The raw release date formatted as "yyyy-MM-dd"
    var rawReleaseDate: String?
    /// The date, the movie was released
    var releaseDate: Date? { rawReleaseDate == nil ? nil : JFUtils.dateFromTMDBString(rawReleaseDate!) }
    
    enum CodingKeys: String, CodingKey {
        // Protocol Properties
        case id
        case title
        case mediaType = "media_type"
        case imagePath = "poster_path"
        case overview
        case originalTitle = "original_title"
        case originalLanguage = "original_language"
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        
        // Exclusive Properties
        case isAdult = "adult"
        case rawReleaseDate = "release_date"
    }
    
}

struct TMDBShowSearchResult: TMDBSearchResult, Identifiable {
    var id: Int
    var title: String
    var mediaType: MediaType
    var imagePath: String?
    var overview: String?
    var originalTitle: String
    var originalLanguage: String
    var popularity: Float
    var voteAverage: Float
    var voteCount: Int
    
    /// The raw first air date formatted as "yyyy-MM-dd"
    var rawFirstAirDate: String
    /// The date, the show was first aired
    var firstAirDate: Date? { JFUtils.dateFromTMDBString(self.rawFirstAirDate) }
    
    enum CodingKeys: String, CodingKey {
        // Protocol Properties
        case id
        case title = "name"
        case mediaType = "media_type"
        case imagePath = "poster_path"
        case overview
        case originalTitle = "original_name"
        case originalLanguage = "original_language"
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        
        // Exclusive Properties
        case rawFirstAirDate = "first_air_date"
    }
}

/// Deocdes a search result as either a `TMDBMovieSearchResult` or a `TMDBShowSearchResult`.
struct SearchResult: PageWrapperProtocol {
    
    private struct Empty: Decodable {}
    
    var results: [TMDBSearchResult]
    var totalPages: Int
    
    /// Initializes the interal results array from the given decoder
    /// - Parameter decoder: The decoder
    init(from decoder: Decoder) throws {
        self.results = []
        // Contains the page and results
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Contains the TMDBSearchResults array
        // Create two identical containers, so we can extract the same value twice
        var arrayContainer = try container.nestedUnkeyedContainer(forKey: .results)
        var arrayContainer2 = try container.nestedUnkeyedContainer(forKey: .results)
        assert(arrayContainer.count == arrayContainer2.count)
        while (!arrayContainer.isAtEnd) {
            // Decode the media object as a GenericMedia to read the type
            let mediaTypeContainer = try arrayContainer.nestedContainer(keyedBy: GenericMedia.CodingKeys.self)
            let mediaType = try mediaTypeContainer.decode(String.self, forKey: .mediaType)
            // Decide based on the media type which type to use for decoding
            switch mediaType {
            case MediaType.movie.rawValue:
                self.results.append(try arrayContainer2.decode(TMDBMovieSearchResult.self))
            case MediaType.show.rawValue:
                self.results.append(try arrayContainer2.decode(TMDBShowSearchResult.self))
            default:
                // Skip the entry (probably type person)
                _ = try? arrayContainer2.decode(Empty.self)
            }
        }
        self.totalPages = try container.decode(Int.self, forKey: .totalPages)
    }
    
    enum CodingKeys: String, CodingKey {
        case results
        case totalPages = "total_pages"
    }
    
    private struct GenericMedia: Codable {
        
        var mediaType: String
        
        enum CodingKeys: String, CodingKey {
            case mediaType = "media_type"
        }
    }
    
}
