//
//  Media+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit
import SwiftUI

extension Media {
    /// The internal library id
    @NSManaged public var id: UUID?
    /// The type of media
    public var type: MediaType {
        get { getEnum(forKey: "type", defaultValue: .movie) }
        set { setEnum(newValue, forKey: "type") }
    }
    /// A rating between 0 and 10 (no Rating and 5 stars)
    public var personalRating: StarRating {
        get { getEnum(forKey: "personalRating", defaultValue: .noRating) }
        set { setEnum(newValue, forKey: "personalRating") }
    }
    /// Whether the user would watch the media again
    public var watchAgain: Bool? {
        get { getOptional(forKey: "watchAgain") }
        set { setOptional(newValue, forKey: "watchAgain") }
    }
    /// Personal notes on the media
    @NSManaged public var notes: String
    
    // MARK: - TMDB Data
    
    // Basic Data
    /// The TMDB ID of the media
    public var tmdbID: Int {
        get { getInt(forKey: "tmdbID") }
        set { setInt(newValue, forKey: "tmdbID") }
    }
    /// The name of the media
    @NSManaged public var title: String
    /// The original tile of the media
    @NSManaged public var originalTitle: String
    /// The path of the media poster image on TMDB
    @NSManaged public var imagePath: String?
    /// A list of genres that match the media
    @NSManaged public var genres: Set<Genre>
    /// A short media description
    @NSManaged public var overview: String?
    /// The tagline of the media
    @NSManaged public var tagline: String?
    /// The status of the media (e.g. Rumored, Planned, In Production, Post Production, Released, Canceled)
    public var status: MediaStatus {
        get { getEnum(forKey: "status", defaultValue: .planned) }
        set { setEnum(newValue, forKey: "status") }
    }
    /// The language the movie was originally created in as an ISO-639-1 string (e.g. 'en')
    @NSManaged public var originalLanguage: String
    
    // Extended Data
    /// A list of companies that produced the media
    @NSManaged public var productionCompanies: Set<ProductionCompany>
    /// The url to the homepage of the media
    @NSManaged public var homepageURL: String?
    /// The ISO 3166 country codes where the media was produced
    @NSManaged public var productionCountries: [String]
    
    // TMDB Scoring
    /// The popularity of the media on TMDB
    @NSManaged public var popularity: Float
    /// The average rating on TMDB
    @NSManaged public var voteAverage: Float
    /// The number of votes that were cast on TMDB
    public var voteCount: Int {
        get { getInt(forKey: "voteCount") }
        set { setInt(newValue, forKey: "voteCount") }
    }
    
    /// The list of cast members, that starred in the media
    @NSManaged public var cast: Set<CastMember>
    /// The sorted list of CastMember IDs for this media
    @NSManaged public var castMembersSortOrder: [Int]
    /// The list of keywords on TheMovieDB.org
    @NSManaged public var keywords: [String]
    /// The list of translations available for the media
    @NSManaged public var translations: [String]
    /// The list of videos available
    @NSManaged public var videos: Set<Video>
    /// A list of user-specified tags
    @NSManaged public var tags: Set<Tag>
    /// The date the media object was created
    @NSManaged public var creationDate: Date
    /// The date the media object was last modified
    @NSManaged public var modificationDate: Date?
    /// The date the media object was released or first aired
    @NSManaged public var releaseDateOrFirstAired: Date?
    /// The color of the parental rating label
    @NSManaged private var parentalRatingColor: SerializableColor?
    /// The parental rating certification of the media
    @NSManaged private var parentalRatingLabel: String?
    /// The streaming sites where is media is available to watch
    @NSManaged public var watchProviders: [WatchProvider]
    
    // MARK: - Computed Properties
    
    /// The parental rating of this media (e.g. FSK 16)
    var parentalRating: ParentalRating? {
        get {
            if let label = parentalRatingLabel {
                return ParentalRating(label, color: parentalRatingColor?.color)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                parentalRatingLabel = newValue.label
                parentalRatingColor = newValue.color.map(SerializableColor.init(from:))
            } else {
                parentalRatingLabel = nil
                parentalRatingColor = nil
            }
        }
    }
    
    /// Whether the result is a movie and is for adults only
    var isAdultMovie: Bool? {
        (self as? Movie)?.isAdult
    }
    
    /// The year of the release or first airing of the media
    var year: Int? {
        var cal = Calendar.current
        cal.timeZone = .utc
        if let releaseDate = (self as? Movie)?.releaseDate {
            return cal.component(.year, from: releaseDate)
        } else if let airDate = (self as? Show)?.firstAirDate {
            return cal.component(.year, from: airDate)
        }
        return nil
    }
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Media> {
        NSFetchRequest<Media>(entityName: "Media")
    }
}

// MARK: Generated accessors for genres
extension Media {
    @objc(addGenresObject:)
    @NSManaged public func addToGenres(_ value: Genre)
    
    @objc(removeGenresObject:)
    @NSManaged public func removeFromGenres(_ value: Genre)
    
    @objc(addGenres:)
    @NSManaged public func addToGenres(_ values: NSSet)
    
    @objc(removeGenres:)
    @NSManaged public func removeFromGenres(_ values: NSSet)
}

// MARK: Generated accessors for videos
extension Media {
    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: Video)
    
    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: Video)
    
    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)
    
    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)
}

// MARK: Generated accessors for productionCompanies
extension Media {
    @objc(addProductionCompaniesObject:)
    @NSManaged public func addToProductionCompanies(_ value: ProductionCompany)
    
    @objc(removeProductionCompaniesObject:)
    @NSManaged public func removeFromProductionCompanies(_ value: ProductionCompany)
    
    @objc(addProductionCompanies:)
    @NSManaged public func addToProductionCompanies(_ values: NSSet)
    
    @objc(removeProductionCompanies:)
    @NSManaged public func removeFromProductionCompanies(_ values: NSSet)
}

// MARK: Generated accessors for cast
extension Media {
    @objc(addCastObject:)
    @NSManaged public func addToCast(_ value: CastMember)
    
    @objc(removeCastObject:)
    @NSManaged public func removeFromCast(_ value: CastMember)
    
    @objc(addCast:)
    @NSManaged public func addToCast(_ values: NSSet)
    
    @objc(removeCast:)
    @NSManaged public func removeFromCast(_ values: NSSet)
}

extension Media: Identifiable {}
