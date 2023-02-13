//
//  ShowToShowV6V7.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

@objc
class ShowToShowV6V7: NSEntityMigrationPolicy {
    // Use the show's watchState for the lastSeasonWatched property
    @objc
    func seasonNumberFor(_ rawWatchState: String) -> NSNumber? {
        guard !rawWatchState.isEmpty else {
            return nil
        }
        return ShowWatchState(rawValue: rawWatchState)!.season as NSNumber?
    }
    
    // Use the show's watchState for the lastEpisodeWatched property
    @objc
    func episodeNumberFor(_ rawWatchState: String) -> NSNumber? {
        guard !rawWatchState.isEmpty else {
            return nil
        }
        return ShowWatchState(rawValue: rawWatchState)!.episode as NSNumber?
    }
}
