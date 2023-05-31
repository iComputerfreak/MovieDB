//
//  Show+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

@objc(Show)
public class Show: Media {
    override public var description: String {
        if isFault {
            return "\(String(describing: Self.self))(isFault: true, objectID: \(objectID))"
        } else {
            return "\(String(describing: Self.self))(id: \(id?.uuidString ?? "nil"), title: \(title), " +
            "rating: \(personalRating.rawValue), watched: \(self.watched?.rawValue ?? "nil"), " +
            "watchAgain: \(self.watchAgain?.description ?? "nil"), tags: \(tags.map(\.name)))"
        }
    }
    
    /// Creates a new `Show` object.
    convenience init(context: NSManagedObjectContext, tmdbData: TMDBData) {
        self.init(context: context)
        initMedia(type: .show, tmdbData: tmdbData)
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set the default watched state according to the user setting
        switch JFConfig.shared.defaultWatchState {
        case .watched:
            self.watched = .season(1)
        case .notWatched:
            self.watched = .notWatched
        case .partiallyWatched:
            self.watched = .episode(season: 1, episode: 1)
        case .unknown:
            self.watched = nil
        }
        
        // TODO: Remove after debugging missing seasons button in detail
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            _ = true
        }
    }
    
    override func initMedia(type: MediaType, tmdbData: TMDBData) {
        super.initMedia(type: type, tmdbData: tmdbData)
        setTMDBShowData(tmdbData)
        // TODO: Remove after debugging missing seasons button in detail
        assert(!self.seasons.isEmpty)
    }
    
    override func update(tmdbData: TMDBData) {
        // Set general TMDBData
        super.update(tmdbData: tmdbData)
        // Set Show specific TMDBData only
        setTMDBShowData(tmdbData)
        // TODO: Remove after debugging missing seasons button in detail
        assert(!self.seasons.isEmpty)
    }
    
    private func setTMDBShowData(_ tmdbData: TMDBData) {
        guard let managedObjectContext else {
            assertionFailure()
            return
        }
        managedObjectContext.performAndWait {
            // This is a show, therefore the TMDBData needs to have show specific data
            let showData = tmdbData.showData!
            self.firstAirDate = showData.firstAirDate
            self.lastAirDate = showData.lastAirDate
            self.numberOfSeasons = showData.numberOfSeasons
            self.numberOfEpisodes = showData.numberOfEpisodes
            self.episodeRuntime = showData.episodeRuntime
            self.isInProduction = showData.isInProduction
            self.seasons = Set(managedObjectContext.importDummies(showData.seasons))
            self.showType = showData.showType
            self.networks = Set(managedObjectContext.importDummies(showData.networks))
            self.createdBy = showData.createdBy
            self.nextEpisodeToAir = showData.nextEpisodeToAir
            self.lastEpisodeToAir = showData.lastEpisodeToAir
        }
    }
    
    override func missingInformation() -> Set<MediaInformation> {
        var missing = super.missingInformation()
        if watched == nil {
            missing.insert(.watched)
        }
        return missing
    }
    
    override func getNextOrLatestReleaseDate() -> Date? {
        // If there are multiple future release dates, we only return the next one
        let airDates = self.seasons.compactMap(\.airDate)
        let futureAirDate = airDates.filter { $0 > .now }
        if let next = futureAirDate.min() {
            // Return the nearest future air date
            return next
        } else if let latest = airDates.max() {
            // No future seasons => return the latest season air date
            return latest
        } else {
            // No air dates available
            return nil
        }
    }
}
