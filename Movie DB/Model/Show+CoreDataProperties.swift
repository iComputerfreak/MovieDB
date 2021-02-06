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

    /// The type of the show (e.g. Scripted)
    @NSManaged public var rawShowType: String?
    /// The season of the episode, the user has watched most recently, or nil, if the user didn't watch this series
    public var lastSeasonWatched: Int64? {
        get { getOptional(forKey: "lastSeasonWatched") }
        set {
            setOptional(newValue, forKey: "lastSeasonWatched")
            // didSet
            if lastSeasonWatched == nil {
                self.missingInformation.insert(.watched)
            } else {
                self.missingInformation.remove(.watched)
            }
        }
    }
    /// The episode number of the episode, the user has watched most recently, or nil, if the user watched a whole season or didn't watch this series
    public var lastEpisodeWatched: Int64? {
        get { getOptional(forKey: "lastEpisodeWatched") }
        set { setOptional(newValue, forKey: "lastEpisodeWatched") }
    }
    /// The date, the show was first aired
    @NSManaged public var firstAirDate: Date?
    /// The date, the show was last aired
    @NSManaged public var lastAirDate: Date?
    /// The number of seasons the show  has
    public var numberOfSeasons: Int64? {
        get { getOptional(forKey: "numberOfSeasons") }
        set { setOptional(newValue, forKey: "numberOfSeasons") }
    }
    /// The number of episodes, the show has
    @NSManaged public var numberOfEpisodes: Int64
    /// The runtime the episodes typically have
    @NSManaged public var episodeRuntime: [Int64]
    /// Whether the show is still in production
    @NSManaged public var isInProduction: Bool
    /// The list of seasons the show has
    @NSManaged public var seasons: NSSet
    /// The list of networks that publish the show
    @NSManaged public var networks: NSSet
    
    public var showType: ShowType? {
        get {
            // If the underlying property is nil, pass it on
            guard let rawShowType = rawShowType else {
                return nil
            }
            return ShowType(rawValue: rawShowType)!
        }
        set {
            guard let newValue = newValue else {
                self.rawShowType = nil
                return
            }
            self.rawShowType = newValue.rawValue
        }
    }

}

// MARK: Generated accessors for seasons
extension Show {
    
    @objc(addSeasonsObject:)
    @NSManaged public func addToSeasons(_ value: Season)
    
    @objc(removeSeasonsObject:)
    @NSManaged public func removeFromSeasons(_ value: Season)
    
    @objc(addSeasons:)
    @NSManaged public func addToSeasons(_ values: NSSet)
    
    @objc(removeSeasons:)
    @NSManaged public func removeFromSeasons(_ values: NSSet)
    
}

// MARK: Generated accessors for networks
extension Show {
    
    @objc(addNetworksObject:)
    @NSManaged public func addToNetworks(_ value: ProductionCompany)
    
    @objc(removeNetworksObject:)
    @NSManaged public func removeFromNetworks(_ value: ProductionCompany)
    
    @objc(addNetworks:)
    @NSManaged public func addToNetworks(_ values: NSSet)
    
    @objc(removeNetworks:)
    @NSManaged public func removeFromNetworks(_ values: NSSet)
    
}
