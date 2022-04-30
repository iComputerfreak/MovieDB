//
//  TMDBData.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/// Represents a set of data about the media from themoviedb.org. Only used for decoding JSON responses
struct TMDBData: Decodable {
    // Basic Data
    var id: Int
    var title: String
    var originalTitle: String
    var imagePath: String?
    var genres: [Genre]
    var tagline: String?
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
    var parentalRating: ParentalRating?
    var watchProviders: [WatchProvider]
    
    var movieData: MovieData?
    var showData: ShowData?
    
    // swiftlint:disable:next function_body_length
    init(from decoder: Decoder) throws {
        guard let decodingContext = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            throw TMDBDataError.noDecodingContext
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decodeAny(String.self, forKeys: [.title, .showTitle])
        self.originalTitle = try container.decodeAny(String.self, forKeys: [.originalTitle, .originalShowTitle])
        self.imagePath = try container.decode(String?.self, forKey: .imagePath)
        self.genres = try container.decode([Genre].self, forKey: .genres)
        self.overview = try container.decode(String?.self, forKey: .overview)
        self.tagline = try container.decode(String?.self, forKey: .tagline)
        self.status = try container.decode(MediaStatus.self, forKey: .status)
        self.originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        self.productionCompanies = try container.decode([ProductionCompany].self, forKey: .productionCompanies)
        self.homepageURL = try container.decode(String?.self, forKey: .homepageURL)
        self.popularity = try container.decode(Float.self, forKey: .popularity)
        self.voteAverage = try container.decode(Float.self, forKey: .voteAverage)
        self.voteCount = try container.decode(Int.self, forKey: .voteCount)
        
        // MARK: Additional data
        
        // Load credits.cast as self.cast
        let creditsContainer: KeyedDecodingContainer<CreditsCodingKeys>
        let cast: [CastMember]
        // If the aggregate_credits key exists, this is a show and we have received the cast for all seasons
        if container.contains(.aggregateCredits) {
            creditsContainer = try container.nestedContainer(keyedBy: CreditsCodingKeys.self, forKey: .aggregateCredits)
            let aggregateCast = try creditsContainer.decode([AggregateCastMember].self, forKey: .cast)
            cast = aggregateCast.map { $0.createCastMember(decodingContext) }
        } else {
            // If this is a normal movie or we did not receive the aggregate credits for some other reason, we use the normal credits
            creditsContainer = try container.nestedContainer(keyedBy: CreditsCodingKeys.self, forKey: .cast)
            cast = try creditsContainer.decode([CastMember].self, forKey: .cast)
        }
        self.cast = cast
        
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
        self.videos = try videosContainer.decode([Video].self, forKey: .results)
        
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
        
        func decodeMovieRating() throws -> ParentalRating? {
            let releaseDates = try container.decode([String: [ReleaseDatesCountry]].self, forKey: .releaseDates)
            let certification: String? = releaseDates["results"]!
                // We are only interested in results for our country
                .filter { $0.countryCode.lowercased() == JFConfig.shared.region.lowercased() }
                // We should only have one result for our country
                .first?
                // We take all the release dates from that country
                .results
                // We don't need release dates without a parental rating
                .filter { !$0.certification.isEmpty }
                // We only want theatrical releases (type 3)
                .first(where: { (release: ReleaseDateCertification) in release.type == 3 })?
                // The parental rating of that release
                .certification
            return certification.flatMap(Utils.parentalRating(for:))
        }
        
        func decodeShowRating() throws -> ParentalRating? {
            let contentRatings = try container.decode(ContentRatingResult.self, forKey: .contentCertifications)
            let certification: String? = contentRatings
                .results
                .first(where: { $0.countryCode.lowercased() == JFConfig.shared.region.lowercased() })?
                .rating
            return certification.flatMap(Utils.parentalRating(for:))
        }
        
        // If we know which type of media we are, we can decode that type of exclusive data only.
        // This way, we still get proper error handling.
        if let mediaType = decoder.userInfo[.mediaType] as? MediaType {
            if mediaType == .movie {
                self.movieData = try MovieData(from: decoder)
                // Load the parental rating from the release dates
                self.parentalRating = try decodeMovieRating()
            } else {
                self.showData = try ShowData(from: decoder)
                // Load the parental rating from the content_ratings
                self.parentalRating = try decodeShowRating()
            }
        } else {
            assertionFailure("Decoding TMDBData without mediaType in the userInfo dict. " +
                             "Please specify the type of media we are decoding! Guessing the type...")
            // If we don't know the type of media, we have to try both and hope one works
            self.movieData = try? MovieData(from: decoder)
            self.showData = try? ShowData(from: decoder)
            if self.movieData != nil {
                self.parentalRating = try decodeMovieRating()
            } else if self.showData != nil {
                self.parentalRating = try decodeShowRating()
            } else {
                fatalError("Unable to decode media object. MediaType is unknown.")
            }
        }
        
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
        case tagline
        case status
        case originalLanguage = "original_language"
        case productionCompanies = "production_companies"
        case homepageURL = "homepage"
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case cast = "credits"
        case aggregateCredits = "aggregate_credits"
        case keywords
        case translations
        case videos
        case releaseDates = "release_dates"
        case contentCertifications = "content_ratings"
        case watchProviders = "watch/providers"
    }
}
