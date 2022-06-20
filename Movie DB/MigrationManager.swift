//
//  MigrationManager.swift
//  Movie DB
//
//  Created by Jonas Frey on 20.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

enum MigrationManager {
    static func run() {
        // Use a for loop with a switch to force this function to be exhaustive
        for migration in MigrationKeys.allCases {
            let alreadyDone = UserDefaults.standard.bool(forKey: migration.rawValue)
            guard !alreadyDone else {
                print("Skipping migration \(migration.rawValue)")
                continue
            }
            print("Executing migration \(migration.rawValue)...")
            // Execute the correct migration
            switch migration {
            case .showLastWatched:
                migrateShowWatchedState()
            }
        }
        print("All migrations done.")
    }
    
    static func migrateShowWatchedState() {
        do {
            let shows = try PersistenceController.viewContext.fetch(Show.fetchRequest())
            for show in shows {
                if let lastWatched = show.lastWatched2 {
                    // Migrate
                    let season = lastWatched.season
                    let episode = lastWatched.episode
                    show.watched = .init(season: season, episode: episode)
                }
            }
            PersistenceController.saveContext()
        } catch {
            print(error)
            assertionFailure("Error migrating show watch states")
        }
    }
    
    private enum MigrationKeys: String, CaseIterable {
        case showLastWatched
    }
}
