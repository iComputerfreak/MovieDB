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
    
    let context = AppDelegate.viewContext
    
    // We only store a single MediaLibrary in the container, therefore we just use the first result
    static let shared: MediaLibrary = MediaLibrary.getInstance()
    
    private static func getInstance() -> MediaLibrary {
        let results = try? AppDelegate.viewContext.fetch(MediaLibrary.fetchRequest())
        if let storedLibrary = results?.first as? MediaLibrary {
            return storedLibrary
        }
        // If there is no library stored, we create a new one
        let newLibrary = MediaLibrary(context: AppDelegate.viewContext)
        try? AppDelegate.viewContext.save()
        
        return newLibrary
    }
    
    /// Updates the media library by updaing every media object with API calls again.
    func update() throws -> Int {
        var updateCount = 0
        let api = TMDBAPI.shared
        let changes = try api.getChanges(from: lastUpdated, to: Date())
        for media in self.mediaList.filter({ changes.contains($0.tmdbID) }) {
            // This media has been changed
            try api.updateMedia(media)
            updateCount += 1
        }
        // After they all have been updated without errors, we can update the lastUpdate property
        self.lastUpdated = Date()
        return updateCount
    }
    
    /// Resets the library, deleting all media objects and resetting the nextID property
    func reset() throws {
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
        try context.save()
    }
    
    func append(_ object: Media) throws {
        self.addToMediaList(object)
        try context.save()
    }
    
    func append(contentsOf objects: [Media]) throws {
        self.addToMediaList(NSSet(objects: objects))
        try context.save()
    }
    
    func remove(id: Int) throws {
        // Fetch the Media with the given ID, remove it from the container and invalidate it in the library
        let request: NSFetchRequest<Media> = Media.fetchRequest()
        request.predicate = NSPredicate(format: "id = \(id)")
        // Fetch the Media with the given ID
        let medias = try context.fetch(request)
        assert(medias.count <= 1, "There are multiple media objects with the same ID in the database.")
        if medias.isEmpty {
            print("Unable to remove Media with ID \(id) since it does not exist.")
            return
        }
        let media = medias.first!
        // Remove the media from the library
        self.removeFromMediaList(media)
        // Remove it from the container
        context.delete(media)
        try context.save()
    }
    
    // MARK: - Problems
    
    /// Returns all problems in this library
    /// - Returns: All problematic media objects and their missing information
    func problems() -> [Media: Set<Media.MediaInformation>] {
        var problems: [Media: Set<Media.MediaInformation>] = [:]
        for media in mediaList {
            if !media.missingInformation.isEmpty {
                problems[media] = media.missingInformation
            }
        }
        return problems
    }
    
    /// Returns the list of duplicate TMDB IDs
    /// - Returns: The list of duplicate TMDB IDs
    func duplicates() -> [Int?: [Media]] {
        // Group the media objects by their TMDB IDs
        return Dictionary(grouping: self.mediaList, by: \.tmdbID)
            // Filter out all IDs with only one media object
            .filter { (key: Int?, value: [Media]) in
                return value.count > 1
            }
    }

}
