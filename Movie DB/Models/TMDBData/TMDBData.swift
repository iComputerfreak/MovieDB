//
//  TMDBData.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit

/// Represents a set of data about the media from themoviedb.org
class TMDBData: Codable, Hashable, ObservableObject {
    // Basic Data
    /// The TMDB ID of the media
    @Published var id: Int
    /// The name of the media
    @Published var title: String
    /// The original tile of the media
    @Published var originalTitle: String
    /// The path of the media poster image on TMDB
    @Published var imagePath: String?
    /// A list of genres that match the media
    @Published var genres: [Genre]
    /// A short media description
    @Published var overview: String?
    /// The status of the media (e.g. Rumored, Planned, In Production, Post Production, Released, Canceled)
    @Published var status: MediaStatus
    /// The language the movie was originally created in as an ISO-639-1 string (e.g. 'en')
    @Published var originalLanguage: String
    
    // Extended Data
    /// A list of companies that produced the media
    @Published var productionCompanies: [ProductionCompany]
    /// The url to the homepage of the media
    @Published var homepageURL: String?
    
    // TMDB Scoring
    /// The popularity of the media on TMDB
    @Published var popularity: Float
    /// The average rating on TMDB
    @Published var voteAverage: Float
    /// The number of votes that were cast on TMDB
    @Published var voteCount: Int
    
    /// The list of cast members, that starred in the media
    @Published var cast: [CastMember]
    /// The list of keywords on TheMovieDB.org
    @Published var keywords: [String]
    /// The list of translations available for the media
    @Published var translations: [String]
    /// The list of videos available
    @Published var videos: [Video]
    
    /// Creates a new TMDBData object
    /// - Important: Never call this initializer directly, always instantiate a concrete subclass!
    init(id: Int, title: String, originalTitle: String, imagePath: String?, genres: [Genre], overview: String?, status: MediaStatus, originalLanguage: String, imdbID: String?, productionCompanies: [ProductionCompany], homepageURL: String?, popularity: Float, voteAverage: Float, voteCount: Int, cast: [CastMember], keywords: [String], translations: [String], videos: [Video]) {
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self.imagePath = imagePath
        self.genres = genres
        self.overview = overview
        self.status = status
        self.originalLanguage = originalLanguage
        self.productionCompanies = productionCompanies
        self.homepageURL = homepageURL
        self.popularity = popularity
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.cast = cast
        self.keywords = keywords
        self.translations = translations
        self.videos = videos
    }
    
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
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
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        // When encoding to disk, we can always use title, never name, because we encode the data only for saving to disk or csv
        // and never return the data to the API
        try container.encode(title, forKey: .title)
        try container.encode(originalTitle, forKey: .originalTitle)
        try container.encode(imagePath, forKey: .imagePath)
        try container.encode(genres, forKey: .genres)
        try container.encode(overview, forKey: .overview)
        try container.encode(status, forKey: .status)
        try container.encode(originalLanguage, forKey: .originalLanguage)
        try container.encode(productionCompanies, forKey: .productionCompanies)
        try container.encode(homepageURL, forKey: .homepageURL)
        try container.encode(popularity, forKey: .popularity)
        try container.encode(voteAverage, forKey: .voteAverage)
        try container.encode(voteCount, forKey: .voteCount)
        
        // Encode self.cast as credits.cast
        var creditsContainer = container.nestedContainer(keyedBy: CreditsCodingKeys.self, forKey: .cast)
        try creditsContainer.encode(self.cast, forKey: .cast)
        
        // Encode self.keywords as keywords.keywords
        var keywordsContainer = container.nestedContainer(keyedBy: KeywordsCodingKeys.self, forKey: .keywords)
        try keywordsContainer.encode(self.keywords.map(Keyword.init(keyword:)), forKey: .keywords)
        
        // Encode self.translations as translations.translations
        var translationsContainer = container.nestedContainer(keyedBy: TranslationsCodingKeys.self, forKey: .translations)
        try translationsContainer.encode(self.translations.map(Translation.init(language:)), forKey: .translations)
        
        // Encode self.videos as videos.results
        var videosContainer = container.nestedContainer(keyedBy: VideosCodingKeys.self, forKey: .videos)
        try videosContainer.encode(self.videos, forKey: .results)
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
    
    // MARK: - Hashable Conformance
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(originalTitle)
        hasher.combine(imagePath)
        hasher.combine(genres)
        hasher.combine(overview)
        hasher.combine(status)
        hasher.combine(originalLanguage)
        hasher.combine(productionCompanies)
        hasher.combine(homepageURL)
        hasher.combine(popularity)
        hasher.combine(voteAverage)
        hasher.combine(voteCount)
        hasher.combine(cast)
        hasher.combine(keywords)
        hasher.combine(translations)
        hasher.combine(videos)
    }
}


