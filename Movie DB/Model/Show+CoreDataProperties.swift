//
//  Show+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData


extension Show {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Show> {
        return NSFetchRequest<Show>(entityName: "Show")
    }

    @NSManaged public var showType: String?
    @NSManaged public var lastEpisodeWatched: EpisodeNumber?
    @NSManaged public var firstAirDate: Date?
    @NSManaged public var lastAirDate: Date?
    @NSManaged public var numberOfSeasons: Int64
    @NSManaged public var numberOfEpisodes: Int64
    @NSManaged public var episodeRuntime: [Int]?
    @NSManaged public var isInProduction: Bool
    @NSManaged public var seasons: [Season]?
    @NSManaged public var networks: [ProductionCompany]?

}
