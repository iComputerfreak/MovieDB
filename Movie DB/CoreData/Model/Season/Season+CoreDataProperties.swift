//
//  Season+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

public extension Season {
    /// The id of the season on TMDB
    var id: Int {
        get { getInt(forKey: Schema.Season.id) }
        set { setInt(newValue, forKey: Schema.Season.id) }
    }

    /// The number of the season
    var seasonNumber: Int {
        get { getInt(forKey: Schema.Season.seasonNumber) }
        set { setInt(newValue, forKey: Schema.Season.seasonNumber) }
    }

    /// The number of episodes, this season has
    var episodeCount: Int {
        get { getInt(forKey: Schema.Season.episodeCount) }
        set { setInt(newValue, forKey: Schema.Season.episodeCount) }
    }

    /// The name of the season
    @NSManaged var name: String
    /// A short description of the season
    @NSManaged var overview: String?
    /// A path to the poster image of the season on TMDB
    @NSManaged var imagePath: String?
    /// The date, the season aired
    @NSManaged var airDate: Date?
    /// The show this season belongs to
    @NSManaged var show: Show?
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Season> {
        NSFetchRequest<Season>(entityName: Schema.Season._entityName)
    }
}

extension Season: Identifiable {}
