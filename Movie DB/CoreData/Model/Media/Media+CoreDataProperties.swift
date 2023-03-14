//
//  Media+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation
import SwiftUI
import UIKit

public extension Media {
    /// The internal library id
    @NSManaged var id: UUID?
    /// The type of media
    var type: MediaType {
        get { getEnum(forKey: Schema.Media.type, defaultValue: .movie) }
        set { setEnum(newValue, forKey: Schema.Media.type) }
    }

    /// A rating between 0 and 10 (no Rating and 5 stars)
    var personalRating: StarRating {
        get { getEnum(forKey: Schema.Media.personalRating, defaultValue: .noRating) }
        set { setEnum(newValue, forKey: Schema.Media.personalRating) }
    }

    /// Whether the user would watch the media again
    var watchAgain: Bool? {
        get { getOptional(forKey: Schema.Media.watchAgain) }
        set { setOptional(newValue, forKey: Schema.Media.watchAgain) }
    }

    /// Personal notes on the media
    @NSManaged var notes: String
    
    // MARK: - TMDB Data
    
    // Basic Data
    /// The TMDB ID of the media
    var tmdbID: Int {
        get { getInt(forKey: Schema.Media.tmdbID) }
        set { setInt(newValue, forKey: Schema.Media.tmdbID) }
    }

    /// The name of the media
    @NSManaged var title: String
    /// The original tile of the media
    @NSManaged var originalTitle: String
    /// The path of the media poster image on TMDB
    @NSManaged var imagePath: String?
    /// A list of genres that match the media
    @NSManaged var genres: Set<Genre>
    /// A short media description
    @NSManaged var overview: String?
    /// The tagline of the media
    @NSManaged var tagline: String?
    /// The status of the media (e.g. Rumored, Planned, In Production, Post Production, Released, Canceled)
    var status: MediaStatus {
        get { getEnum(forKey: Schema.Media.status, defaultValue: .planned) }
        set { setEnum(newValue, forKey: Schema.Media.status) }
    }

    /// The language the movie was originally created in as an ISO-639-1 string (e.g. 'en')
    @NSManaged var originalLanguage: String
    
    // Extended Data
    /// A list of companies that produced the media
    @NSManaged var productionCompanies: Set<ProductionCompany>
    /// The url to the homepage of the media
    @NSManaged var homepageURL: String?
    /// The ISO 3166 country codes where the media was produced
    @NSManaged var productionCountries: [String]
    
    // TMDB Scoring
    /// The popularity of the media on TMDB
    @NSManaged var popularity: Float
    /// The average rating on TMDB
    @NSManaged var voteAverage: Float
    /// The number of votes that were cast on TMDB
    var voteCount: Int {
        get { getInt(forKey: Schema.Media.voteCount) }
        set { setInt(newValue, forKey: Schema.Media.voteCount) }
    }
    
    /// The list of keywords on TheMovieDB.org
    @NSManaged var keywords: [String]
    /// The list of translations available for the media
    @NSManaged var translations: [String]
    /// The list of videos available
    @NSManaged var videos: Set<Video>
    /// A list of user-specified tags
    @NSManaged var tags: Set<Tag>
    /// The date the media object was created
    @NSManaged var creationDate: Date
    /// The date the media object was last modified
    @NSManaged var modificationDate: Date?
    /// The date the media object was released or first aired
    @NSManaged var releaseDateOrFirstAired: Date?
    /// The parental rating of this media (e.g. FSK 16)
    @NSManaged var parentalRating: ParentalRating?
    /// The streaming sites where is media is available to watch
    @NSManaged var watchProviders: Set<WatchProvider>
    /// Whether this media has been marked as a favorite
    @NSManaged var isFavorite: Bool
    /// Whether this media has been added to the watchlist
    @NSManaged var isOnWatchlist: Bool
    /// The user lists this media is associated with
    @NSManaged var userLists: Set<UserMediaList>
    
    // MARK: - Computed Properties
    
    /// Whether the result is a movie and is for adults only
    internal var isAdultMovie: Bool? {
        (self as? Movie)?.isAdult
    }
    
    /// The year of the release or first airing of the media
    internal var year: Int? {
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
    class func fetchRequest() -> NSFetchRequest<Media> {
        NSFetchRequest<Media>(entityName: Schema.Media._entityName)
    }
}

extension Media: Identifiable {}
