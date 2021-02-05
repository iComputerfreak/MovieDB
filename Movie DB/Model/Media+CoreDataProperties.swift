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


extension Media {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Media> {
        return NSFetchRequest<Media>(entityName: "Media")
    }

    /// The internal library id
    @NSManaged public var id: Int64
    /// The type of media
    @NSManaged public var type: MediaType
    /// A rating between 0 and 10 (no Rating and 5 stars)
    @NSManaged public var personalRating: StarRating
    /// A list of user-specified tags, listed by their id
    @NSManaged public var tags: [Int]
    /// Whether the user would watch the media again
    @NSManaged public var watchAgain: Bool
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
    @NSManaged public var genres: [Genre]
    /// A short media description
    @NSManaged public var overview: String?
    /// The status of the media (e.g. Rumored, Planned, In Production, Post Production, Released, Canceled)
    @NSManaged public var status: MediaStatus
    /// The language the movie was originally created in as an ISO-639-1 string (e.g. 'en')
    @NSManaged public var originalLanguage: String
    
    // Extended Data
    /// A list of companies that produced the media
    @NSManaged public var productionCompanies: [ProductionCompany]
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
    @NSManaged public var cast: [CastMember]
    /// The list of keywords on TheMovieDB.org
    @NSManaged public var keywords: [String]
    /// The list of translations available for the media
    @NSManaged public var translations: [String]
    /// The list of videos available
    @NSManaged public var videos: [Video]
    
    /// The set of missing information of this media
    @NSManaged public var missingInformation: Set<MediaInformation>
    
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

    
}

extension Media : Identifiable {

}
