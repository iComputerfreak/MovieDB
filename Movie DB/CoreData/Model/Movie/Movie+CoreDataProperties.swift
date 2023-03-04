//
//  Movie+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

public extension Movie {
    /// Whether the user has watched the media
    var watched: MovieWatchState? {
        get { getOptionalEnum(forKey: Schema.Movie.watchedState) }
        set { setOptionalEnum(newValue, forKey: Schema.Movie.watchedState) }
    }

    /// Runtime in minutes
    var runtime: Int? {
        get { getOptionalInt(forKey: Schema.Movie.runtime) }
        set { setOptionalInt(newValue, forKey: Schema.Movie.runtime) }
    }

    /// The date, the movie was released
    var releaseDate: Date? {
        get { getOptional(forKey: Schema.Movie.releaseDate) }
        set {
            setOptional(newValue, forKey: Schema.Movie.releaseDate)
            // Update the convenience property
            releaseDateOrFirstAired = newValue
        }
    }

    /// The production budget in dollars
    var budget: Int {
        get { getInt(forKey: Schema.Movie.budget) }
        set { setInt(newValue, forKey: Schema.Movie.budget) }
    }

    /// The revenue in dollars
    var revenue: Int {
        get { getInt(forKey: Schema.Movie.revenue) }
        set { setInt(newValue, forKey: Schema.Movie.revenue) }
    }

    /// Whether the movie is an adult movie
    @NSManaged var isAdult: Bool
    /// The id of the media on IMDB.com
    @NSManaged var imdbID: String?
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Movie> {
        NSFetchRequest<Movie>(entityName: Schema.Movie._entityName)
    }
}
