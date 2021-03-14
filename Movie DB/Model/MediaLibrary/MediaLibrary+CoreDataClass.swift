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
            
            let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K IN %@", "tmdbID", changedIDs)
            let medias = (try? self.libraryContext.fetch(fetchRequest)) ?? []
            for media in medias {
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
        // Delete all Medias from the context
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        let allMedias = (try? libraryContext.fetch(fetchRequest)) ?? []
        for media in allMedias {
            libraryContext.delete(media)
            // Thumbnail and Video objects will be automatically deleted by the cascading delete rule
        }
        // Reset the ID counter for the media objects
        MediaLibrary.shared.resetNextID()
        PersistenceController.saveContext(context: libraryContext)
    }
        
    /// Resets the nextID property
    func resetNextID() {
        self.nextID = 1
    }
    
    /// Resets the nextID property
    func resetNextTagID() {
        self.nextTagID = 1
    }
}
