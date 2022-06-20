//
//  Show+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Show)
public class Show: Media {
    // MARK: - Initializers
    
    /// Creates a new `Show` object.
    convenience init(context: NSManagedObjectContext, tmdbData: TMDBData) {
        self.init(context: context)
        self.initMedia(type: .show, tmdbData: tmdbData)
    }
    
    override func initMedia(type: MediaType, tmdbData: TMDBData) {
        super.initMedia(type: type, tmdbData: tmdbData)
        setTMDBShowData(tmdbData)
    }
    
    override func update(tmdbData: TMDBData) {
        assert(
            managedObjectContext != PersistenceController.viewContext,
            "Media updates should not be done in the view context. " +
            "Modifications should be done on a background context to prevent an inconsistent view context state"
        )
        print("[JF] Updating in MOC \(managedObjectContext?.name ?? "nil")")
        // Set general TMDBData
        super.update(tmdbData: tmdbData)
        // Set Show specific TMDBData only
        setTMDBShowData(tmdbData)
    }
    
    private func setTMDBShowData(_ tmdbData: TMDBData) {
        guard let managedObjectContext = managedObjectContext else {
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
}
