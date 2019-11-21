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

struct SearchResult: Codable {
    struct Empty: Decodable {}
    
    var results: [TMDBSearchResult]
    
    init(from decoder: Decoder) throws {
        self.results = []
        // Contains the page and results
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Contains the TMDBSearchResults array
        var arrayContainer = try container.nestedUnkeyedContainer(forKey: .results)  //.nestedContainer(keyedBy: NestedCodingKeys.self, forKey: .results)
        var arrayContainer2 = try container.nestedUnkeyedContainer(forKey: .results)
        assert(arrayContainer.count == arrayContainer2.count)
        while (!arrayContainer.isAtEnd) {
            let mediaTypeContainer = try arrayContainer.nestedContainer(keyedBy: GenericMedia.CodingKeys.self)
            let mediaType = try mediaTypeContainer.decode(String.self, forKey: .mediaType)
            //let media = arrayContainer.decode(GenericMedia.self)
            switch mediaType {
            case "movie":
                self.results.append(try arrayContainer2.decode(TMDBMovieSearchResult.self))
            case "tv":
                if let a = try? arrayContainer2.decode(TMDBShowSearchResult.self) {
                    self.results.append(a)
                } else {
                    let b = try arrayContainer2.decode(TMDBMovieData.self)
                    print(b)
                }
            default:
                // Skip the other entry (probably type person)
                _ = try? arrayContainer2.decode(Empty.self)
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        print("ENCODING")
        fatalError()
    }
    
    enum CodingKeys: String, CodingKey {
        case results
    }
    
    private struct GenericMedia: Codable {
        
        var mediaType: String
        
        enum CodingKeys: String, CodingKey {
            case mediaType = "media_type"
        }
    }
    
}
