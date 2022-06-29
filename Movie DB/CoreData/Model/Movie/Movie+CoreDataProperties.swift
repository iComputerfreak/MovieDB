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
        get { getOptionalEnum(forKey: "watchedState") }
        set { setOptionalEnum(newValue, forKey: "watchedState") }
    }

    /// Runtime in minutes
    var runtime: Int? {
        get { getOptionalInt(forKey: "runtime") }
        set { setOptionalInt(newValue, forKey: "runtime") }
    }

    /// The date, the movie was released
    var releaseDate: Date? {
        get { getOptional(forKey: "releaseDate") }
        set {
            setOptional(newValue, forKey: "releaseDate")
            // Update the convenience property
            releaseDateOrFirstAired = newValue
        }
    }

    /// The production budget in dollars
    var budget: Int {
        get { getInt(forKey: "budget") }
        set { setInt(newValue, forKey: "budget") }
    }

    /// The revenue in dollars
    var revenue: Int {
        get { getInt(forKey: "revenue") }
        set { setInt(newValue, forKey: "revenue") }
    }

    /// Whether the movie is an adult movie
    @NSManaged var isAdult: Bool
    /// The id of the media on IMDB.com
    @NSManaged var imdbID: String?
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Movie> {
        NSFetchRequest<Movie>(entityName: "Movie")
    }
}
