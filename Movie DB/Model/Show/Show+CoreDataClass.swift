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
        // This is a show, therefore the TMDBData needs to have show specific data
        let showData = tmdbData.showData!
        self.firstAirDate = showData.firstAirDate
        self.lastAirDate = showData.lastAirDate
        self.numberOfSeasons = showData.numberOfSeasons
        self.numberOfEpisodes = showData.numberOfEpisodes
        self.episodeRuntime = showData.episodeRuntime
        self.isInProduction = showData.isInProduction
        self.seasons = Set(showData.seasons)
        self.showType = showData.showType
        self.networks = Set(showData.networks)
    }

}
