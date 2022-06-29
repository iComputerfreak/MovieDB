//
//  Show+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

extension Show {
    /// Whether the user has watched the show
    public var watched: ShowWatchState? {
        get { getOptionalEnum(forKey: "showWatchState") }
        set { setOptionalEnum(newValue, forKey: "showWatchState") }
    }
    /// The type of the show (e.g. Scripted)
    public var showType: ShowType? {
        get { getOptionalEnum(forKey: "showType") }
        set { setOptionalEnum(newValue, forKey: "showType") }
    }
    /// The season of the episode, the user has watched most recently, or nil, if the user didn't watch this series
    public var lastSeasonWatched2: Int? {
        get { getOptionalInt(forKey: "lastSeasonWatched") }
        set { setOptionalInt(newValue, forKey: "lastSeasonWatched") }
    }
    /// The episode number of the episode, the user has watched most recently, or nil, if the user watched a whole season or didn't watch this series
    public var lastEpisodeWatched2: Int? {
        get { getOptionalInt(forKey: "lastEpisodeWatched") }
        set { setOptionalInt(newValue, forKey: "lastEpisodeWatched") }
    }
    /// The date, the show was first aired
    public var firstAirDate: Date? {
        get { getOptional(forKey: "firstAirDate") }
        set {
            setOptional(newValue, forKey: "firstAirDate")
            // Update the convenience property
            self.releaseDateOrFirstAired = newValue
        }
    }
    /// The date, the show was last aired
    @NSManaged public var lastAirDate: Date?
    /// The number of seasons the show  has
    public var numberOfSeasons: Int? {
        get { getOptionalInt(forKey: "numberOfSeasons") }
        set { setOptionalInt(newValue, forKey: "numberOfSeasons") }
    }
    /// The number of episodes, the show has
    public var numberOfEpisodes: Int {
        get { getInt(forKey: "numberOfEpisodes") }
        set { setInt(newValue, forKey: "numberOfEpisodes") }
    }
    /// The runtime the episodes typically have
    @NSManaged public var episodeRuntime: [Int]
    /// Whether the show is still in production
    @NSManaged public var isInProduction: Bool
    /// The list of seasons the show has
    @NSManaged public var seasons: Set<Season>
    /// The list of networks that publish the show
    @NSManaged public var networks: Set<ProductionCompany>
    /// The list of names of the people who created this show
    @NSManaged public var createdBy: [String]
    @NSManaged public var nextEpisodeToAir: Episode?
    @NSManaged public var lastEpisodeToAir: Episode?
    
    public var lastWatched2: EpisodeNumber? {
        get {
            guard let lastSeason = self.lastSeasonWatched2 else {
                return nil
            }
            return EpisodeNumber(season: lastSeason, episode: lastEpisodeWatched2)
        }
        set {
            guard let episodeNumber = newValue else {
                self.lastSeasonWatched2 = nil
                self.lastEpisodeWatched2 = nil
                return
            }
            self.lastSeasonWatched2 = episodeNumber.season
            self.lastEpisodeWatched2 = episodeNumber.episode
        }
    }
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Show> {
        NSFetchRequest<Show>(entityName: "Show")
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
