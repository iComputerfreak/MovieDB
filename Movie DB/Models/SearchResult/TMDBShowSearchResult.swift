//
//  TMDBShowSearchResult.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

class TMDBShowSearchResult: TMDBSearchResult {
    /// The date, the show was first aired
    let firstAirDate: Date?
    
    /// Creates a new `TMDBShowSearchResult` object with the given values
    init(id: Int,
         title: String,
         mediaType: MediaType,
         imagePath: String? = nil,
         overview: String? = nil,
         originalTitle: String,
         originalLanguage: String,
         popularity: Float,
         voteAverage: Float,
         voteCount: Int,
         firstAirDate: Date? = nil) {
        self.firstAirDate = firstAirDate
        super.init(id: id,
                   title: title,
                   mediaType: mediaType,
                   imagePath: imagePath,
                   overview: overview,
                   originalTitle: originalTitle,
                   originalLanguage: originalLanguage,
                   popularity: popularity,
                   voteAverage: voteAverage,
                   voteCount: voteCount)
    }
    
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // If the decoded raw date is nil, we use "" to produce a nil date in the line below
        let rawFirstAirDate = try container.decodeIfPresent(String.self, forKey: .rawFirstAirDate) ?? ""
        self.firstAirDate = Utils.tmdbDateFormatter.date(from: rawFirstAirDate)
        
        try super.init(from: decoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case rawFirstAirDate = "first_air_date"
    }
}
