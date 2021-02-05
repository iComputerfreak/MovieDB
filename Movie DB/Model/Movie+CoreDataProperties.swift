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

    @NSManaged public var runtime: Int64
    @NSManaged public var releaseDate: Date?
    @NSManaged public var budget: Int64
    @NSManaged public var revenue: Int64
    @NSManaged public var tagline: String?
    @NSManaged public var isAdult: Bool
    @NSManaged public var imdbID: String?
    @NSManaged public var watched: Bool

}
