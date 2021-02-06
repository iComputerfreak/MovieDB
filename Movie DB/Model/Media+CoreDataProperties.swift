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


extension Media {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Media> {
        return NSFetchRequest<Media>(entityName: "Media")
    }

    /// The internal library id
    @NSManaged public var id: Int64
    /// The raw type of media, meaning the MediaType rawValue (e.g. "movie" or "show")
    @NSManaged public var rawType: String
    /// The raw personal rating. Don't set this property manually. Use `personalRating`.
    @NSManaged public var rawPersonalRating: Int64
    /// A list of user-specified tags, listed by their id
    public var tags: [Int] {
        get {
            getTransformerValue(forKey: "tags")
        }
        set {
            setTransformerValue(newValue, forKey: "tags")
            // didSet
            if tags.isEmpty {
                self.missingInformation.insert(.tags)
            } else {
                self.missingInformation.remove(.tags)
            }
        }
    }
    /// Whether the user would watch the media again
    public var watchAgain: Bool? {
        get { getOptional(forKey: "watchAgain") }
        set {
            setOptional(newValue, forKey: "watchAgain")
            // didSet
            if watchAgain == nil {
                self.missingInformation.insert(.watchAgain)
            } else {
                self.missingInformation.remove(.watchAgain)
            }
        }
    }
    /// Personal notes on the media
    @NSManaged public var notes: String
    /// The thumbnail image
    @NSManaged public var thumbnail: UIImage?
    
    // MARK: - TMDB Data
    
    // Basic Data
    /// The TMDB ID of the media
    @NSManaged public var tmdbID: Int64
    /// The name of the media
    @NSManaged public var title: String
    /// The original tile of the media
    @NSManaged public var originalTitle: String
    /// The path of the media poster image on TMDB
    @NSManaged public var imagePath: String?
    /// A list of genres that match the media
    @NSManaged public var genres: NSSet
    /// A short media description
    @NSManaged public var overview: String?
    /// The status of the media (e.g. Rumored, Planned, In Production, Post Production, Released, Canceled)
    @NSManaged public var rawStatus: String
    /// The language the movie was originally created in as an ISO-639-1 string (e.g. 'en')
    @NSManaged public var originalLanguage: String
    
    // Extended Data
    /// A list of companies that produced the media
    @NSManaged public var productionCompanies: NSSet
    /// The url to the homepage of the media
    @NSManaged public var homepageURL: String?
    
    // TMDB Scoring
    /// The popularity of the media on TMDB
    @NSManaged public var popularity: Float
    /// The average rating on TMDB
    @NSManaged public var voteAverage: Float
    /// The number of votes that were cast on TMDB
    @NSManaged public var voteCount: Int64
    
    /// The list of cast members, that starred in the media
    @NSManaged public var cast: NSSet
    /// The list of keywords on TheMovieDB.org
    @NSManaged public var keywords: [String]
    /// The list of translations available for the media
    @NSManaged public var translations: [String]
    /// The list of videos available
    @NSManaged public var videos: NSSet
    
    /// The set of missing information of this media
    @NSManaged public var rawMissingInformation: Set<String>
    
    // MARK: - Computed Properties
    
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
    
    /// The type of media
    var type: MediaType {
        get {
            return MediaType(rawValue: rawType)!
        }
        set {
            self.rawType = newValue.rawValue
        }
    }
    
    /// A rating between 0 and 10 (no Rating and 5 stars)
    var personalRating: StarRating {
        get {
            return StarRating(rawValue: Int(rawPersonalRating))!
        }
        set {
            self.rawPersonalRating = Int64(newValue.rawValue)
            // didSet
            if newValue == .noRating {
                self.missingInformation.insert(.rating)
            } else {
                self.missingInformation.remove(.rating)
            }
        }
    }
    
    public var status: MediaStatus {
        get {
            return MediaStatus(rawValue: rawStatus)!
        }
        set {
            self.rawStatus = newValue.rawValue
        }
    }
    
    /// The set of missing information of this media
    public var missingInformation: Set<MediaInformation> {
        get {
            return Set(rawMissingInformation.map({ MediaInformation(rawValue: $0)! }))
        }
        set {
            self.rawMissingInformation = Set(newValue.map(\.rawValue))
        }
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

extension Media : Identifiable {
    
}
