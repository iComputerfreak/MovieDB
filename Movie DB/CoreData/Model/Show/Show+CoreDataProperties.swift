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

public extension Show {
    /// Whether the user has watched the show
    var watched: ShowWatchState? {
        get { getOptionalEnum(forKey: "showWatchState") }
        set { setOptionalEnum(newValue, forKey: "showWatchState") }
    }

    /// The type of the show (e.g. Scripted)
    var showType: ShowType? {
        get { getOptionalEnum(forKey: "showType") }
        set { setOptionalEnum(newValue, forKey: "showType") }
    }

    // TODO: Remove when migrated on all devices (iOS 16)
    /// The season of the episode, the user has watched most recently, or nil, if the user didn't watch this series
    var lastSeasonWatched2: Int? {
        get { getOptionalInt(forKey: "lastSeasonWatched") }
        set { setOptionalInt(newValue, forKey: "lastSeasonWatched") }
    }

    /// The episode number of the episode, the user has watched most recently, or nil, if the user watched a whole season or didn't watch this series
    var lastEpisodeWatched2: Int? {
        get { getOptionalInt(forKey: "lastEpisodeWatched") }
        set { setOptionalInt(newValue, forKey: "lastEpisodeWatched") }
    }

    /// The date, the show was first aired
    var firstAirDate: Date? {
        get { getOptional(forKey: "firstAirDate") }
        set {
            setOptional(newValue, forKey: "firstAirDate")
            // Update the convenience property
            releaseDateOrFirstAired = newValue
        }
    }

    /// The date, the show was last aired
    @NSManaged var lastAirDate: Date?
    /// The number of seasons the show  has
    var numberOfSeasons: Int? {
        get { getOptionalInt(forKey: "numberOfSeasons") }
        set { setOptionalInt(newValue, forKey: "numberOfSeasons") }
    }

    /// The number of episodes, the show has
    var numberOfEpisodes: Int {
        get { getInt(forKey: "numberOfEpisodes") }
        set { setInt(newValue, forKey: "numberOfEpisodes") }
    }

    /// The runtime the episodes typically have
    @NSManaged var episodeRuntime: [Int]
    /// Whether the show is still in production
    @NSManaged var isInProduction: Bool
    /// The list of seasons the show has
    @NSManaged var seasons: Set<Season>
    /// The list of networks that publish the show
    @NSManaged var networks: Set<ProductionCompany>
    /// The list of names of the people who created this show
    @NSManaged var createdBy: [String]
    @NSManaged var nextEpisodeToAir: Episode?
    @NSManaged var lastEpisodeToAir: Episode?
    
    var lastWatched2: EpisodeNumber? {
        get {
            guard let lastSeason = lastSeasonWatched2 else {
                return nil
            }
            return EpisodeNumber(season: lastSeason, episode: lastEpisodeWatched2)
        }
        set {
            guard let episodeNumber = newValue else {
                lastSeasonWatched2 = nil
                lastEpisodeWatched2 = nil
                return
            }
            lastSeasonWatched2 = episodeNumber.season
            lastEpisodeWatched2 = episodeNumber.episode
        }
    }
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Show> {
        NSFetchRequest<Show>(entityName: "Show")
    }
}

// MARK: Generated accessors for seasons
public extension Show {
    @objc(addSeasonsObject:)
    @NSManaged func addToSeasons(_ value: Season)
    
    @objc(removeSeasonsObject:)
    @NSManaged func removeFromSeasons(_ value: Season)
    
    @objc(addSeasons:)
    @NSManaged func addToSeasons(_ values: NSSet)
    
    @objc(removeSeasons:)
    @NSManaged func removeFromSeasons(_ values: NSSet)
}

// MARK: Generated accessors for networks
public extension Show {
    @objc(addNetworksObject:)
    @NSManaged func addToNetworks(_ value: ProductionCompany)
    
    @objc(removeNetworksObject:)
    @NSManaged func removeFromNetworks(_ value: ProductionCompany)
    
    @objc(addNetworks:)
    @NSManaged func addToNetworks(_ values: NSSet)
    
    @objc(removeNetworks:)
    @NSManaged func removeFromNetworks(_ values: NSSet)
}
