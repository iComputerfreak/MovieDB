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
    /// The watch state of the show (unknown, not watched or watched up to a spefic season or episode)
    var watched: ShowWatchState? {
        get {
            guard let lastSeasonWatched else {
                return nil
            }
            return .init(season: lastSeasonWatched, episode: lastEpisodeWatched)
        }
        set {
            if let newValue {
                // If the season property is nil, we use -1 for "unknown"
                lastSeasonWatched = newValue.season ?? -1
                lastEpisodeWatched = newValue.episode
            } else {
                // Set the values to "unknown"
                lastSeasonWatched = -1
                lastEpisodeWatched = 0
            }
        }
    }

    /// The type of the show (e.g. Scripted)
    var showType: ShowType? {
        get { getOptionalEnum(forKey: Schema.Show.showType) }
        set { setOptionalEnum(newValue, forKey: Schema.Show.showType) }
    }

    /// The season of the episode, the user has watched most recently, or nil, if the user didn't watch this series
    private var lastSeasonWatched: Int? {
        get { getOptionalInt(forKey: Schema.Show.lastSeasonWatched) }
        set { setOptionalInt(newValue, forKey: Schema.Show.lastSeasonWatched) }
    }

    /// The episode number of the episode, the user has watched most recently, or nil, if the user watched a whole season or didn't watch this series
    private var lastEpisodeWatched: Int? {
        get { getOptionalInt(forKey: Schema.Show.lastEpisodeWatched) }
        set { setOptionalInt(newValue, forKey: Schema.Show.lastEpisodeWatched) }
    }

    /// The date, the show was first aired
    var firstAirDate: Date? {
        get { getOptional(forKey: Schema.Show.firstAirDate) }
        set {
            setOptional(newValue, forKey: Schema.Show.firstAirDate)
            // Update the convenience property
            releaseDateOrFirstAired = newValue
        }
    }

    /// The date, the show was last aired
    @NSManaged var lastAirDate: Date?
    /// The number of seasons the show  has
    var numberOfSeasons: Int? {
        get { getOptionalInt(forKey: Schema.Show.numberOfSeasons) }
        set { setOptionalInt(newValue, forKey: Schema.Show.numberOfSeasons) }
    }

    /// The number of episodes, the show has
    var numberOfEpisodes: Int {
        get { getInt(forKey: Schema.Show.numberOfEpisodes) }
        set { setInt(newValue, forKey: Schema.Show.numberOfEpisodes) }
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
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Show> {
        NSFetchRequest<Show>(entityName: Schema.Show._entityName)
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
