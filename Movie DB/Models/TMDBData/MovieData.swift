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
            Utils.tmdbUTCDateFormatter.date(from: rawReleaseDate)
        }

        var runtime: Int?
        var budget: Int
        var revenue: Int
        var isAdult: Bool
        var imdbID: String?
        var directors: [String]
        
        init(
            rawReleaseDate: String,
            runtime: Int? = nil,
            budget: Int,
            revenue: Int,
            isAdult: Bool,
            imdbID: String? = nil,
            directors: [String]
        ) {
            self.rawReleaseDate = rawReleaseDate
            self.runtime = runtime
            self.budget = budget
            self.revenue = revenue
            self.isAdult = isAdult
            self.imdbID = imdbID
            self.directors = directors
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.rawReleaseDate = try container.decode(String.self, forKey: .rawReleaseDate)
            self.runtime = try container.decode(Int?.self, forKey: .runtime)
            self.budget = try container.decode(Int.self, forKey: .budget)
            self.revenue = try container.decode(Int.self, forKey: .revenue)
            self.isAdult = try container.decode(Bool.self, forKey: .isAdult)
            self.imdbID = try container.decode(String?.self, forKey: .imdbID)
            
            // Load the director(s)
            let creditsContainer = try container.nestedContainer(keyedBy: CreditsCodingKeys.self, forKey: .credits)
            let crew = try creditsContainer.decode([CrewMemberDummy].self, forKey: .crew)
            // We only store the director(s) for now
            let directors = crew.filter { $0.job == "Director" }
            self.directors = directors.map(\.name)
        }
        
        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case rawReleaseDate = "release_date"
            case runtime
            case budget
            case revenue
            case isAdult = "adult"
            case imdbID = "imdb_id"
            case credits
        }
        
        // swiftlint:disable:next nesting
        enum CreditsCodingKeys: CodingKey {
            case crew
        }
    }
}
