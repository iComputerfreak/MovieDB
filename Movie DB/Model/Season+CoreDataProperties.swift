//
//  Season+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData


extension Season {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Season> {
        return NSFetchRequest<Season>(entityName: "Season")
    }

    /// The id of the season on TMDB
    @NSManaged public var id: Int64
    /// The number of the season
    @NSManaged public var seasonNumber: Int64
    /// The number of episodes, this season has
    @NSManaged public var episodeCount: Int64
    /// The name of the season
    @NSManaged public var name: String
    /// A short description of the season
    @NSManaged public var overview: String?
    /// A path to the poster image of the season on TMDB
    @NSManaged public var imagePath: String?
    /// The date, the season aired
    @NSManaged public var airDate: Date?
    /// The show this season belongs to
    @NSManaged public var show: Show?

}

extension Season : Identifiable {

}
