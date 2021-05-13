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
    
    // Don't use a stored property to prevent accessing the viewContext from a background thread (during NSManagedObject creation)
    var libraryContext: NSManagedObjectContext {
        self.managedObjectContext ?? PersistenceController.viewContext
    }
    
    // We only store a single MediaLibrary in the container, therefore we just use the first result
    static let shared: MediaLibrary = MediaLibrary.getInstance()
    
    private static func getInstance() -> MediaLibrary {
        let results = try? PersistenceController.viewContext.fetch(MediaLibrary.fetchRequest())
        if let storedLibrary = results?.first as? MediaLibrary {
            return storedLibrary
        }
        // If there is no library stored, we create a new one
        let newLibrary = MediaLibrary(context: PersistenceController.viewContext)
        PersistenceController.saveContext()
        
        return newLibrary
    }
    
    /// Updates the media library by updaing every media object with API calls again.
    func update(completion: ((Int?, Error?) -> Void)? = nil) {
        var updateCount = 0
        let api = TMDBAPI.shared
        api.getChangedIDs(from: lastUpdated, to: Date()) { (changedIDs: [Int]?, error: Error?) in
            
            if let error = error {
                print("Error fetching changes: \(error)")
                completion?(nil, error)
                return
            }
            
            guard let changedIDs = changedIDs else {
                print("Error fetching changes. Returned changes are nil.")
                completion?(nil, nil)
                return
            }
            
            let updateContext: NSManagedObjectContext = PersistenceController.viewContext.newBackgroundContext()
            updateContext.name = "Update Context (\(updateContext.name ?? "unknown"))"
            
            let group = DispatchGroup()
            var lastError: Error? = nil
            let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K IN %@", "tmdbID", changedIDs)
            let medias = (try? self.libraryContext.fetch(fetchRequest)) ?? []
            print("Updating \(medias.count) media objects.")
            for media in medias {
                group.enter()
                // This media has been changed
                api.updateMedia(media, context: updateContext) { error in
                    if let error = error {
                        print("Error updating media object with TMMDB ID \(media.tmdbID): \(error)")
                        // Pass down the error, but keep updating
                        lastError = error
                    }
                    // We need to download the thumbnail again on the view context
                    DispatchQueue.main.async {
                        if let mainMedia = PersistenceController.viewContext.object(with: media.objectID) as? Media {
                            // Call it on the media object in the viewContext, not on the mediaObject in the background context
                            mainMedia.loadThumbnailAsync(force: true)
                        } else {
                            print("Media object does not exist in the viewContext yet. Cannot load thumbnail.")
                            assertionFailure()
                        }
                    }
                    updateCount += 1
                    group.leave()
                }
            }
            group.wait()
            // After they all have been updated without errors, we can update the lastUpdate property
            self.lastUpdated = Date()
            // Save the updated media into the parent context (viewContext)
            PersistenceController.saveContext(context: updateContext)
            completion?(updateCount, lastError)
        }
    }
    
    /// Fixes all duplicates IDs by assigning new IDs to the media objects
    @objc static func fixDuplicates(notification: Notification?) {
        // TODO: Fix duplicate TMDB IDs
        // New data has just been merged from iCloud. Check for duplicates
        let allMedia = JFUtils.allMedias()
        let grouped = Dictionary(grouping: allMedia, by: \.id)
        for group in grouped.values {
            guard group.count > 1 else {
                continue
            }
            // If the group has multiple entries, there are multiple media objects with the same ID
            // For all media objects, except the first
            for i in 1..<group.count {
                let media = group[i]
                // Assign a new, free ID
                media.id = UUID()
            }
        }
        
    }
    
    /// Reloads all media objects in the library by re-fetching their TMDBData
    /// - Parameter completion: A closure that will be executed when the reload has finished, providing the last occurred error
    func reloadAll(completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            // TODO: Pass down multiple errors, generated by the update calls
            let api = TMDBAPI.shared
            var latestError: Error? = nil
            let reloadContext: NSManagedObjectContext = PersistenceController.viewContext.newBackgroundContext()
            reloadContext.name = "Reload Context (\(reloadContext.name ?? "unknown"))"
            
            let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
            let medias = (try? self.libraryContext.fetch(fetchRequest)) ?? []
            print("Reloading \(medias.count) media objects.")
            let group = DispatchGroup()
            for media in medias {
                group.enter()
                api.updateMedia(media, context: reloadContext) { error in
                    if let error = error {
                        print("Error reloading media object with TMMDB ID \(media.tmdbID): \(error)")
                        // Report the error in the completion closure, but continue with the execution
                        latestError = error
                    }
                    // We need to download the thumbnail again on the view context
                    DispatchQueue.main.async {
                        if let mainMedia = PersistenceController.viewContext.object(with: media.objectID) as? Media {
                            // Call it on the media object in the viewContext, not on the mediaObject in the background context
                            mainMedia.loadThumbnailAsync(force: true)
                        } else {
                            print("Media object does not exist in the viewContext yet. Cannot load thumbnail.")
                            assertionFailure()
                        }
                    }
                    // Leave the group when the media has been updated
                    group.leave()
                }
            }
            // Wait for all updates to finish
            group.wait()
            // Save the reloaded media into the parent context (viewContext)
            PersistenceController.saveContext(context: reloadContext)
            completion?(latestError)
        }
    }
    
    /// Resets the library, deleting all media objects and resetting the nextID property
    func reset() throws {
        // Delete all Medias from the context
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        let allMedias = (try? libraryContext.fetch(fetchRequest)) ?? []
        for media in allMedias {
            libraryContext.delete(media)
            // Thumbnail and Video objects will be automatically deleted by the cascading delete rule
        }
        // Reset the ID counter for the media objects
        PersistenceController.saveContext(context: libraryContext)
    }
}
