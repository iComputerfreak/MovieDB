//
//  AppStoreScreenshotData.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

/// The data loaded when starting the app with the appropriate command line argument for doing app store screenshots through UI tests
struct AppStoreScreenshotData {
    let context: NSManagedObjectContext
    
    private enum TagName {
        case future
        case conspiracy
        case dark
        case violent
        case gangsters
        case terrorist
        case past
        case fantasy
        case comedy
        case timeTravel
        case space
    }
    
    private var tags: [TagName: Tag] = [:]
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        // Create some tags
        self.tags = [
            .future: Tag(name: "Future", context: context),
            .conspiracy: Tag(name: "Conspiracy", context: context),
            .dark: Tag(name: "Dark", context: context),
            .violent: Tag(name: "Violent", context: context),
            .gangsters: Tag(name: "Gangsters", context: context),
            .terrorist: Tag(name: "Terrorist", context: context),
            .past: Tag(name: "Past", context: context),
            .fantasy: Tag(name: "Fantasy", context: context),
            .comedy: Tag(name: "Comedy", context: context),
            .timeTravel: Tag(name: "Time Travel", context: context),
            .space: Tag(name: "Space", context: context),
        ]
    }
    
    // swiftlint:disable force_cast
    func prepareSampleData() async throws {
        // MARK: Create Movies and Shows
        let api = TMDBAPI.shared
        
        // MARK: Fetch medias
        // Matrix
        let matrix = try await api.media(for: 603, type: .movie, context: context) as! Movie
        let loki = try await api.media(for: 84958, type: .show, context: context) as! Show
        let expanse = try await api.media(for: 63639, type: .show, context: context) as! Show
        let drwho = try await api.media(for: 57243, type: .show, context: context) as! Show
        
        await context.perform {
            // MARK: Configure properties
            matrix.personalRating = .fourStars
            matrix.watched = .watched
            matrix.watchAgain = true
            matrix.watchDate = .now
            matrix.tags = getTags([.future, .conspiracy])
            matrix.notes = "A pretty good movie!"
            
            loki.personalRating = .fiveStars
            loki.watched = .notWatched
            loki.watchAgain = nil
            loki.tags = getTags([.comedy])
            loki.notes = "Can't wait for another season!"
            loki.isOnWatchlist = true
            
            expanse.personalRating = .fourAndAHalfStars
            expanse.watched = .episode(season: 5, episode: 3)
            expanse.watchAgain = false
            expanse.watchDate = .now.addingTimeInterval(-12 * .day)
            expanse.tags = getTags([.future, .space])
            expanse.notes = ""
            expanse.isFavorite = true
            
            drwho.personalRating = .fiveStars
            drwho.watched = .season(12)
            drwho.watchAgain = true
            drwho.watchDate = .now.addingTimeInterval(-60 * .day)
            drwho.tags = getTags([.future, .timeTravel, .space])
            drwho.notes = ""
            drwho.isOnWatchlist = true
            drwho.isFavorite = true
        }
    }
    
    // swiftlint:enable force_cast
    
    private func getTags(_ tags: [TagName]) -> Set<Tag> {
        Set(tags.map { self.tags[$0]! })
    }
}
