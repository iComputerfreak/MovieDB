//
//  TMDBMovieData.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

struct TMDBMovieData: TMDBData {
    // Protocol properties
    var id: Int
    var title: String
    var originalTitle: String
    var imagePath: String?
    var genres: [Genre]
    var overview: String?
    var status: String
    var originalLanguage: String
    var imdbID: String?
    var productionCompanies: [ProductionCompany]
    var homepageURL: String?
    var popularity: Float
    var voteAverage: Float
    var voteCount: Int
    
    var castWrapper: CastWrapper?
    var keywordsWrapper: KeywordsWrapper?
    var translationsWrapper: TranslationsWrapper?
    var videosWrapper: VideosWrapper?
    
    // Exclusive Properties
    /// The raw release date formatted as "yyyy-MM-dd"
    var rawReleaseDate: String
    /// The year, the movie was released
    var releaseDate: Date? { JFUtils.dateFromTMDBString(self.rawReleaseDate) }
    /// Runtime in minutes
    var runtime: Int?
    /// The production budget in dollars
    var budget: Int
    /// The revenue in dollars
    var revenue: Int
    /// The tagline of the movie
    var tagline: String?
    /// Whether the movie is an adult movie
    var isAdult: Bool
    
    enum CodingKeys: String, CodingKey {
        // Protocol Properties
        case id
        case title
        case originalTitle = "original_title"
        case imagePath = "poster_path"
        case genres = "genres"
        case overview
        case status
        case originalLanguage = "original_language"
        case imdbID = "imdb_id"
        case productionCompanies = "production_companies"
        case homepageURL = "homepage"
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        
        // Exclusive properties
        case rawReleaseDate = "release_date"
        case runtime
        case budget
        case revenue
        case tagline
        case isAdult = "adult"
        
        // Filled externally by separate API calls
        //case keywordsWrapper, castWrapper, translationsWrapper, videosWrapper
    }
}
