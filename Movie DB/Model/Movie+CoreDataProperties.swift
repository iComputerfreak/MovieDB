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
        set {
            setOptional(newValue, forKey: "watched")
            // didSet
            if watched == nil {
                self.missingInformation.insert(.watched)
            } else {
                self.missingInformation.remove(.watched)
            }
        }
    }
    /// Runtime in minutes
    public var runtime: Int64? {
        get { getOptional(forKey: "runtime") }
        set { setOptional(newValue, forKey: "runtime") }
    }
    /// The date, the movie was released
    @NSManaged public var releaseDate: Date?
    /// The production budget in dollars
    @NSManaged public var budget: Int64
    /// The revenue in dollars
    @NSManaged public var revenue: Int64
    /// The tagline of the movie
    @NSManaged public var tagline: String?
    /// Whether the movie is an adult movie
    @NSManaged public var isAdult: Bool
    /// The id of the media on IMDB.com
    @NSManaged public var imdbID: String?

}
