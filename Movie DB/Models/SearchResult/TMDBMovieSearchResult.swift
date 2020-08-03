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
    var isAdult: Bool
    /// The date, the movie was released
    var releaseDate: Date?
    
    init(id: Int, title: String, mediaType: MediaType, imagePath: String? = nil, overview: String? = nil, originalTitle: String, originalLanguage: String, popularity: Float, voteAverage: Float, voteCount: Int, isAdult: Bool, releaseDate: Date? = nil) {
        self.isAdult = isAdult
        self.releaseDate = releaseDate
        super.init(id: id, title: title, mediaType: mediaType, imagePath: imagePath, overview: overview, originalTitle: originalTitle, originalLanguage: originalLanguage, popularity: popularity, voteAverage: voteAverage, voteCount: voteCount)
    }
    
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.isAdult = try container.decode(Bool.self, forKey: .isAdult)
        
        // If the decoded raw date is nil, we use "" to produce a nil date in the line below
        let rawReleaseDate = try container.decode(String?.self, forKey: .rawReleaseDate) ?? ""
        self.releaseDate = JFUtils.tmdbDateFormatter.date(from: rawReleaseDate)
        
        try super.init(from: decoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case isAdult = "adult"
        case rawReleaseDate = "release_date"
    }
    
}
