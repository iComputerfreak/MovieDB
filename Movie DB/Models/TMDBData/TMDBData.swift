//
//  TMDBData.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit

/// Represents a set of data about the media from themoviedb.org. Only used for decoding JSON responses
struct TMDBData: Decodable, Hashable {
    // Basic Data
    var id: Int
    var title: String
    var originalTitle: String
    var imagePath: String?
    var genres: [Genre]
    var overview: String?
    var status: MediaStatus
    var originalLanguage: String
    
    // Extended Data
    var productionCompanies: [ProductionCompany]
    var homepageURL: String?
    
    // TMDB Scoring
    var popularity: Float
    var voteAverage: Float
    var voteCount: Int
    
    var cast: [CastMember]
    var keywords: [String]
    var translations: [String]
    var videos: [Video]
    
    var movieData: MovieData?
    var showData: ShowData?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decodeAny(String.self, forKeys: [.title, .showTitle])
        self.originalTitle = try container.decodeAny(String.self, forKeys: [.originalTitle, .originalShowTitle])
        self.imagePath = try container.decode(String?.self, forKey: .imagePath)
        self.genres = try container.decode([Genre].self, forKey: .genres)
        self.overview = try container.decode(String?.self, forKey: .overview)
        self.status = try container.decode(MediaStatus.self, forKey: .status)
        self.originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        self.productionCompanies = try container.decode([ProductionCompany].self, forKey: .productionCompanies)
        self.homepageURL = try container.decode(String?.self, forKey: .homepageURL)
        self.popularity = try container.decode(Float.self, forKey: .popularity)
        self.voteAverage = try container.decode(Float.self, forKey: .voteAverage)
        self.voteCount = try container.decode(Int.self, forKey: .voteCount)
        
        // Load credits.cast as self.cast
        let creditsContainer = try container.nestedContainer(keyedBy: CreditsCodingKeys.self, forKey: .cast)
        self.cast = try creditsContainer.decode([CastMember].self, forKey: .cast)
        
        // Load keywords.keywords as self.keywords
        let keywordsContainer = try container.nestedContainer(keyedBy: KeywordsCodingKeys.self, forKey: .keywords)
        let keywords = try keywordsContainer.decodeAny([Keyword].self, forKeys: [.keywords, .showKeywords])
        // Only save the keywords themselves
        self.keywords = keywords.map(\.keyword)
        
        // Load translations.translations as self.translations
        let translationsContainer = try container.nestedContainer(keyedBy: TranslationsCodingKeys.self, forKey: .translations)
        let translations = try translationsContainer.decode([Translation].self, forKey: .translations)
        // Only save the languages, not the Translation objects
        self.translations = translations.map(\.language)
        
        // Load videos.results as self.videos
        let videosContainer = try container.nestedContainer(keyedBy: VideosCodingKeys.self, forKey: .videos)
        self.videos = try videosContainer.decode([Video].self, forKey: .results)
        
        // Decode exclusive data (we don't know if what we are decoding is a movie or a show)
        self.movieData = try? MovieData(from: decoder)
        self.showData = try? ShowData(from: decoder)
        
        assert(!(self.movieData == nil && self.showData == nil), "Error decoding movie/show data for '\(self.title)'")
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case showTitle = "name"
        case originalTitle = "original_title"
        case originalShowTitle = "original_name"
        case imagePath = "poster_path"
        case genres = "genres"
        case overview
        case status
        case originalLanguage = "original_language"
        case productionCompanies = "production_companies"
        case homepageURL = "homepage"
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case cast = "credits"
        case keywords
        case translations
        case videos
    }
    
    private enum VideosCodingKeys: String, CodingKey {
        case results
    }
    
    private enum CreditsCodingKeys: String, CodingKey {
        case cast
    }
    
    private enum KeywordsCodingKeys: String, CodingKey {
        case keywords
        case showKeywords = "results"
    }
    
    private enum TranslationsCodingKeys: String, CodingKey {
        case translations
    }
    
    // Is directly mapped to the language when decoding
    private struct Translation: Codable, Hashable {
        var language: String
        
        enum CodingKeys: String, CodingKey {
            case language = "english_name"
        }
    }
    
    // Is directly mapped to the keyword when decoding
    private struct Keyword: Codable, Hashable {
        var keyword: String
        
        enum CodingKeys: String, CodingKey {
            case keyword = "name"
        }
    }
    
    // MARK: - Movie / Show exclusive data
    
    struct MovieData: Decodable, Hashable {
        var rawReleaseDate: String
        var releaseDate: Date? {
            JFUtils.tmdbDateFormatter.date(from: rawReleaseDate)
        }
        var runtime: Int?
        var budget: Int
        var revenue: Int
        var tagline: String?
        var isAdult: Bool
        var imdbID: String?
        
        enum CodingKeys: String, CodingKey {
            case rawReleaseDate = "release_date"
            case runtime
            case budget
            case revenue
            case tagline
            case isAdult = "adult"
            case imdbID = "imdb_id"
        }
    }
    
    struct ShowData: Decodable, Hashable {
        var rawFirstAirDate: String
        var firstAirDate: Date? {
            JFUtils.tmdbDateFormatter.date(from: rawFirstAirDate)
        }
        var rawLastAirDate: String
        var lastAirDate: Date? {
            JFUtils.tmdbDateFormatter.date(from: rawLastAirDate)
        }
        var numberOfSeasons: Int?
        var numberOfEpisodes: Int
        var episodeRuntime: [Int]
        var isInProduction: Bool
        var seasons: [Season]
        var showType: ShowType?
        var networks: [ProductionCompany]
        
        enum CodingKeys: String, CodingKey {
            case rawFirstAirDate = "first_air_date"
            case rawLastAirDate = "last_air_date"
            case numberOfSeasons = "number_of_seasons"
            case numberOfEpisodes = "number_of_episodes"
            case episodeRuntime = "episode_run_time"
            case isInProduction = "in_production"
            case seasons
            case showType = "type"
            case networks
        }
    }
}


