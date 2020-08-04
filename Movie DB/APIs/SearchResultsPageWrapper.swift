//
//  SearchResultsPageWrapper.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

/// Deocdes a search result as either a `TMDBMovieSearchResult` or a `TMDBShowSearchResult`.
struct SearchResultsPageWrapper: PageWrapperProtocol {
    
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
