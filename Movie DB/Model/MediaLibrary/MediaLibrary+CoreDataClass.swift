//
//  MediaLibrary+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

/// Represents a wrapper for the Media array conforming to `ObservableObject` and adding a few convenience functions
@objc(MediaLibrary)
public class MediaLibrary: NSManagedObject {
    
    // TODO: Save library after adding media
    
    static let shared: MediaLibrary = AppDelegate.viewContext
    
    /// Updates the media library by updaing every media object with API calls again.
    func update() throws -> Int {
        var updateCount = 0
        let api = TMDBAPI.shared
        let changes = try api.getChanges(from: lastUpdate, to: Date())
        for media in self.mediaList.filter({ changes.contains($0.tmdbID) }) {
            // This media has been changed
            try api.updateMedia(media)
            updateCount += 1
        }
        // After they all have been updated without errors, we can update the lastUpdate property
        self.lastUpdate = Date()
        return updateCount
    }
    
    /// Resets the library, deleting all media objects and resetting the nextID property
    func reset() {
        self.mediaList.removeAll()
        // Delete all thumbnails
        do {
            try FileManager.default.removeItem(at: JFUtils.url(for: "thumbnails"))
            try FileManager.default.createDirectory(at: JFUtils.url(for: "thumbnails"), withIntermediateDirectories: true)
        } catch let error {
            print("Error deleting thumbnails: \(error)")
        }
        // Reset the ID counter for the media objects
        MediaID.resetNextID()
        save()
    }

}
