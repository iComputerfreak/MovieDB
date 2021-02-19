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
    
    /// Resets the nextID property
    func resetNextID() {
        self.nextID = 1
    }
    
    // Don't use a stored property to prevent accessing the viewContext from a background thread (during NSManagedObject creation)
    var context: NSManagedObjectContext {
        CoreDataStack.viewContext
    }
    
    // We only store a single MediaLibrary in the container, therefore we just use the first result
    static let shared: MediaLibrary = MediaLibrary.getInstance()
    
    private static func getInstance() -> MediaLibrary {
        let results = try? CoreDataStack.viewContext.fetch(MediaLibrary.fetchRequest())
        if let storedLibrary = results?.first as? MediaLibrary {
            return storedLibrary
        }
        // If there is no library stored, we create a new one
        let newLibrary = MediaLibrary(context: CoreDataStack.viewContext)
        CoreDataStack.saveContext()
        
        return newLibrary
    }
    
    /// Updates the media library by updaing every media object with API calls again.
    func update(completion: @escaping (Int?, Error?) -> Void) {
        var updateCount = 0
        let api = TMDBAPI.shared
        api.getChanges(from: lastUpdated, to: Date()) { (changedIDs: [Int]?, error: Error?) in
            
            if let error = error {
                print("Error fetching changes: \(error)")
                completion(nil, error)
                return
            }
            
            guard let changedIDs = changedIDs else {
                print("Error fetching changes. Returned changes are nil.")
                completion(nil, nil)
                return
            }
            
            for media in self.mediaList.filter({ changedIDs.contains($0.tmdbID) }) {
                // This media has been changed
                api.updateMedia(media) { error in
                    guard let error = error else { return }
                    print("Error updating media object with TMMDB ID \(media.tmdbID): \(error)")
                }
                updateCount += 1
            }
            // After they all have been updated without errors, we can update the lastUpdate property
            self.lastUpdated = Date()
            completion(updateCount, nil)
        }
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
        MediaLibrary.shared.resetNextID()
        try context.save()
    }
    
    func append(_ object: Media) throws {
        // This media object may come from another context
        let libraryMOC = self.managedObjectContext
        let media = libraryMOC?.object(with: object.objectID) as! Media
        print("Adding media object: \(media)")
        print(media.title)
        print(media.tags)
        self.addToMediaList(media)
        try context.save()
    }
    
    func append(contentsOf objects: [Media]) throws {
        // This media object may come from another context
        let libraryMOC = self.managedObjectContext
        let medias = objects.map { media in
            return libraryMOC?.object(with: media.objectID) as! Media
        }
        self.addToMediaList(NSSet(objects: medias))
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
        for media in self.mediaList {
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
