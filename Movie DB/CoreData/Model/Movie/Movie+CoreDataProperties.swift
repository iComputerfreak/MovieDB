//
//  Movie+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    /// Whether the user has watched the media (partly or fully)
    public var watched: Bool? {
        get { getOptional(forKey: "watched") }
        set { setOptional(newValue, forKey: "watched") }
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
    /// The tagline of the movie
    @NSManaged public var tagline: String?
    /// Whether the movie is an adult movie
    @NSManaged public var isAdult: Bool
    /// The id of the media on IMDB.com
    @NSManaged public var imdbID: String?

}
