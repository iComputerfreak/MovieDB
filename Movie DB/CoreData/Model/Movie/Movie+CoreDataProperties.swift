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

extension Movie {
    /// Whether the user has watched the media
    public var watched: MovieWatchState? {
        get { getOptionalEnum(forKey: "watchedState") }
        set { setOptionalEnum(newValue, forKey: "watchedState") }
    }
    /// Runtime in minutes
    public var runtime: Int? {
        get { getOptionalInt(forKey: "runtime") }
        set { setOptionalInt(newValue, forKey: "runtime") }
    }
    /// The date, the movie was released
    public var releaseDate: Date? {
        get { getOptional(forKey: "releaseDate") }
        set {
            setOptional(newValue, forKey: "releaseDate")
            // Update the convenience property
            self.releaseDateOrFirstAired = newValue
        }
    }
    /// The production budget in dollars
    public var budget: Int {
        get { getInt(forKey: "budget") }
        set { setInt(newValue, forKey: "budget") }
    }
    /// The revenue in dollars
    public var revenue: Int {
        get { getInt(forKey: "revenue") }
        set { setInt(newValue, forKey: "revenue") }
    }
    /// Whether the movie is an adult movie
    @NSManaged public var isAdult: Bool
    /// The id of the media on IMDB.com
    @NSManaged public var imdbID: String?
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Movie> {
        NSFetchRequest<Movie>(entityName: "Movie")
    }
}
