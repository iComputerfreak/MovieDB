//
//  MovieData.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

extension TMDBData {
    struct MovieData: Decodable, Hashable {
        var rawReleaseDate: String
        var releaseDate: Date? {
            Utils.tmdbDateFormatter.date(from: rawReleaseDate)
        }
        var runtime: Int?
        var budget: Int
        var revenue: Int
        var isAdult: Bool
        var imdbID: String?
        
        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case rawReleaseDate = "release_date"
            case runtime
            case budget
            case revenue
            case isAdult = "adult"
            case imdbID = "imdb_id"
        }
    }
}
