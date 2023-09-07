//
//  TMDBData.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import UIKit

/// Represents a set of data about the media from themoviedb.org. Only used for decoding JSON responses
struct TMDBData: Decodable {
    // Basic Data
    var id: Int
    var title: String
    var originalTitle: String
    var imagePath: String?
    var genres: [GenreDummy]
    var tagline: String?
    var overview: String?
    var status: MediaStatus
    var originalLanguage: String
    
    // Extended Data
    var productionCompanies: [ProductionCompanyDummy]
    var homepageURL: String?
    var productionCountries: [String]
    
    // TMDB Scoring
    var popularity: Float
    var voteAverage: Float
    var voteCount: Int
    
    var keywords: [String]
    var translations: [String]
    var videos: [VideoDummy]
    var parentalRating: ParentalRatingDummy?
    var watchProviders: [WatchProviderDummy]
    
    var movieData: MovieData?
    var showData: ShowData?
    
    init(
        id: Int,
        title: String,
        originalTitle: String,
        imagePath: String? = nil,
        genres: [GenreDummy],
        tagline: String? = nil,
        overview: String? = nil,
        status: MediaStatus,
        originalLanguage: String,
        productionCompanies: [ProductionCompanyDummy],
        homepageURL: String? = nil,
        productionCountries: [String],
        popularity: Float,
        voteAverage: Float,
        voteCount: Int,
        keywords: [String],
        translations: [String],
        videos: [VideoDummy],
        parentalRating: ParentalRatingDummy? = nil,
        watchProviders: [WatchProviderDummy],
        movieData: Self.MovieData? = nil,
        showData: Self.ShowData? = nil
    ) {
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self.imagePath = imagePath
        self.genres = genres
        self.tagline = tagline
        self.overview = overview
        self.status = status
        self.originalLanguage = originalLanguage
        self.productionCompanies = productionCompanies
        self.homepageURL = homepageURL
        self.productionCountries = productionCountries
        self.popularity = popularity
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.keywords = keywords
        self.translations = translations
        self.videos = videos
        self.parentalRating = parentalRating
        self.watchProviders = watchProviders
        self.movieData = movieData
        self.showData = showData
    }
    
    // swiftlint:disable:next function_body_length
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decodeAny(String.self, forKeys: [.title, .showTitle])
        originalTitle = try container.decodeAny(String.self, forKeys: [.originalTitle, .originalShowTitle])
        imagePath = try container.decode(String?.self, forKey: .imagePath)
        genres = try container.decode([GenreDummy].self, forKey: .genres)
        overview = try container.decode(String?.self, forKey: .overview)
        tagline = try container.decode(String?.self, forKey: .tagline)
        status = try container.decode(MediaStatus.self, forKey: .status)
        originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        productionCompanies = try container.decode([ProductionCompanyDummy].self, forKey: .productionCompanies)
        homepageURL = try container.decode(String?.self, forKey: .homepageURL)
        productionCountries = try container
            .decode([ProductionCountry].self, forKey: .productionCountries)
            .map(\.iso3166) // Store the iso country codes
        popularity = try container.decode(Float.self, forKey: .popularity)
        voteAverage = try container.decode(Float.self, forKey: .voteAverage)
        voteCount = try container.decode(Int.self, forKey: .voteCount)
        
        // MARK: Additional data
        
        // Load keywords.keywords as self.keywords
        let keywordsContainer = try container.nestedContainer(keyedBy: KeywordsCodingKeys.self, forKey: .keywords)
        let keywords = try keywordsContainer.decodeAny([Keyword].self, forKeys: [.keywords, .showKeywords])
        // Only save the keywords themselves
        self.keywords = keywords.map(\.keyword)
        
        // Load translations.translations as self.translations
        let translationsContainer = try container.nestedContainer(
            keyedBy: TranslationsCodingKeys.self,
            forKey: .translations
        )
        let translations = try translationsContainer.decode([Translation].self, forKey: .translations)
        // Only save the languages, not the Translation objects
        self.translations = translations.map(\.language)
        
        // Load videos.results as self.videos
        let videosContainer = try container.nestedContainer(keyedBy: GenericResultsCodingKeys.self, forKey: .videos)
        videos = try videosContainer.decode([VideoDummy].self, forKey: .results)
        
        // Load the watch providers
        let watchProvidersContainer = try container.nestedContainer(
            keyedBy: GenericResultsCodingKeys.self,
            forKey: .watchProviders
        )
        let results = try watchProvidersContainer.decode([String: WatchProviderResult].self, forKey: .results)
        // Get the correct providers for the configured region
        let result = results[JFConfig.shared.region]
        self.watchProviders = result?.providers ?? []
        
        // MARK: Movie/Show specific
        
        func decodeMovieRating() throws -> ParentalRatingDummy? {
            let releaseDates = try container.decode([String: [ReleaseDatesCountry]].self, forKey: .releaseDates)
            let releaseDatesCountry: ReleaseDatesCountry? = releaseDates["results"]!
                // We are only interested in results for our country
                // We should only have one result for our country
                .first(where: { $0.countryCode.lowercased() == JFConfig.shared.region.lowercased() })
            
            // Store the actual decoded country code
            guard let countryCode = releaseDatesCountry?.countryCode else {
                // If we didn't find a matching country, we can return here already
                return nil
            }
            
            let certification: ReleaseDateCertification? = releaseDatesCountry?
                // We take all the release dates from that country
                .results
                // We don't need release dates without a parental rating
                // We only want theatrical releases (type 3)
                .first { release in
                    !release.certification.isEmpty && release.type == 3
                }
            
            // If we found a result, return it
            if let certification {
                return .init(countryCode: countryCode, label: certification.certification)
            }
            return nil
        }
        
        func decodeShowRating() throws -> ParentalRatingDummy? {
            let contentRatings = try container.decode(ContentRatingResult.self, forKey: .contentCertifications)
            let certification: ContentRatingDummy? = contentRatings
                .results
                .first(where: { $0.countryCode.lowercased() == JFConfig.shared.region.lowercased() })
            if let certification {
                return .init(countryCode: certification.countryCode, label: certification.rating)
            }
            return nil
        }
        
        // If we know which type of media we are, we can decode that type of exclusive data only.
        // This way, we still get proper error handling.
        if let mediaType = decoder.userInfo[.mediaType] as? MediaType {
            if mediaType == .movie {
                movieData = try MovieData(from: decoder)
                // Load the parental rating from the release dates
                parentalRating = try decodeMovieRating()
            } else {
                showData = try ShowData(from: decoder)
                // Load the parental rating from the content_ratings
                parentalRating = try decodeShowRating()
            }
        } else {
            assertionFailure("Decoding TMDBData without mediaType in the userInfo dict. " +
                "Please specify the type of media we are decoding! Guessing the type...")
            // If we don't know the type of media, we have to try both and hope one works
            movieData = try? MovieData(from: decoder)
            showData = try? ShowData(from: decoder)
            if movieData != nil {
                parentalRating = try decodeMovieRating()
            } else if showData != nil {
                parentalRating = try decodeShowRating()
            } else {
                fatalError("Unable to decode media object. MediaType is unknown.")
            }
        }
        
        assert(!(movieData == nil && showData == nil), "Error decoding movie/show data for '\(title)'")
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
        case tagline
        case status
        case originalLanguage = "original_language"
        case productionCompanies = "production_companies"
        case homepageURL = "homepage"
        case productionCountries = "production_countries"
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case keywords
        case translations
        case videos
        case releaseDates = "release_dates"
        case contentCertifications = "content_ratings"
        case watchProviders = "watch/providers"
    }
}
