//
//  Movie.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

class Movie: Media {
        
    /// Whether the user has watched the media (partly or fully)
    @Published var watched: Bool? = nil {
        didSet {
            if watched == nil {
                self.missingInformation.insert(.watched)
            } else {
                self.missingInformation.remove(.watched)
            }
        }
    }
    
    // MARK: - TMDB Data
    
    /// The date, the movie was released
    @Published var releaseDate: Date?
    /// Runtime in minutes
    @Published var runtime: Int?
    /// The production budget in dollars
    @Published var budget: Int
    /// The revenue in dollars
    @Published var revenue: Int
    /// The tagline of the movie
    @Published var tagline: String?
    /// Whether the movie is an adult movie
    @Published var isAdult: Bool
    /// The id of the media on IMDB.com
    @Published var imdbID: String?
    
    /// Creates a new `Movie` object
    init(tmdbData: TMDBData) {
        // This is a movie, therefore the TMDBData needs to have movie specific data
        let movieData = tmdbData.movieData!
        self.releaseDate = movieData.releaseDate
        self.runtime = movieData.runtime
        self.budget = movieData.budget
        self.revenue = movieData.revenue
        self.tagline = movieData.tagline
        self.isAdult = movieData.isAdult
        self.imdbID = movieData.imdbID
        super.init(type: .movie, tmdbData: tmdbData)
    }
    
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.watched = try container.decode(Bool?.self, forKey: .watched)
        self.releaseDate = try container.decode(Date.self, forKey: .releaseDate)
        self.runtime = try container.decode(Int?.self, forKey: .runtime)
        self.budget = try container.decode(Int.self, forKey: .budget)
        self.revenue = try container.decode(Int.self, forKey: .revenue)
        self.tagline = try container.decode(String?.self, forKey: .tagline)
        self.isAdult = try container.decode(Bool.self, forKey: .isAdult)
        self.imdbID = try container.decode(String?.self, forKey: .imdbID)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.watched, forKey: .watched)
        try container.encode(releaseDate, forKey: .releaseDate)
        try container.encode(runtime, forKey: .runtime)
        try container.encode(budget, forKey: .budget)
        try container.encode(revenue, forKey: .revenue)
        try container.encode(tagline, forKey: .tagline)
        try container.encode(isAdult, forKey: .isAdult)
        try container.encode(imdbID, forKey: .imdbID)
    }
    
    private enum CodingKeys: CodingKey {
        case watched
        case releaseDate
        case runtime
        case budget
        case revenue
        case tagline
        case isAdult
        case imdbID
    }
    
    // MARK: - Hashable Conformance
    
    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(watched)
        hasher.combine(releaseDate)
        hasher.combine(runtime)
        hasher.combine(budget)
        hasher.combine(revenue)
        hasher.combine(tagline)
        hasher.combine(isAdult)
        hasher.combine(imdbID)
    }
    
    // MARK: - Repairable Conformance
    override func repair(progress: Binding<Double>? = nil) -> RepairProblems {
        let problems = super.repair(progress: progress)
        // Sadly, we cannot update the progress correctly this way, but since the action here only takes a quick moment, we will just ignore the overhead
        if self.watched == nil {
            DispatchQueue.main.async {
                self.missingInformation.insert(.watched)
            }
        }
        return problems
    }
}
