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
    /// The id of the season on TMDB
    public var id: Int {
        get { getInt(forKey: "id") }
        set { setInt(newValue, forKey: "id") }
    }
    /// The number of the season
    public var seasonNumber: Int {
        get { getInt(forKey: "seasonNumber") }
        set { setInt(newValue, forKey: "seasonNumber") }
    }
    /// The number of episodes, this season has
    public var episodeCount: Int {
        get { getInt(forKey: "episodeCount") }
        set { setInt(newValue, forKey: "episodeCount") }
    }
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
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Season> {
        NSFetchRequest<Season>(entityName: "Season")
    }
}

extension Season: Identifiable {}
