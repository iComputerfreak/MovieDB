//
//  TMDBMovieSearchResult.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

class TMDBMovieSearchResult: TMDBSearchResult {
    /// Whether the movie is an adult movie
    let isAdult: Bool
    /// The date, the movie was released
    let releaseDate: Date?
    
    /// Creates a new `TMDBMovieSearchResult` object with the given values
    init(
        id: Int,
        title: String,
        mediaType: MediaType,
        imagePath: String? = nil,
        overview: String? = nil,
        originalTitle: String,
        originalLanguage: String,
        popularity: Float,
        voteAverage: Float,
        voteCount: Int,
        isAdult: Bool,
        releaseDate: Date? = nil
    ) {
        self.isAdult = isAdult
        self.releaseDate = releaseDate
        super.init(
            id: id,
            title: title,
            mediaType: mediaType,
            imagePath: imagePath,
            overview: overview,
            originalTitle: originalTitle,
            originalLanguage: originalLanguage,
            popularity: popularity,
            voteAverage: voteAverage,
            voteCount: voteCount
        )
    }
    
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        isAdult = try container.decode(Bool.self, forKey: .isAdult)
        
        // If the decoded raw date is nil, we use "" to produce a nil date in the line below
        // We use decodeIfPresent here, because it could be possible, that the API response does not contains the key
        // (had this once)
        let rawReleaseDate = try container.decodeIfPresent(String.self, forKey: .rawReleaseDate) ?? ""
        releaseDate = Utils.tmdbDateFormatter.date(from: rawReleaseDate)
        
        try super.init(from: decoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case isAdult = "adult"
        case rawReleaseDate = "release_date"
    }
    
    // MARK: Hashable Conformance
    
    override func hash(into hasher: inout Hasher) {
        hasher.combine(isAdult)
        hasher.combine(releaseDate)
    }
    
    static func == (lhs: TMDBMovieSearchResult, rhs: TMDBMovieSearchResult) -> Bool {
        let superLhs = lhs as TMDBSearchResult
        let superRhs = rhs as TMDBSearchResult
        return superLhs == superRhs &&
            lhs.isAdult == rhs.isAdult &&
            lhs.releaseDate == rhs.releaseDate
    }
}
