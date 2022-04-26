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
import SwiftUI

/// Represents a wrapper for the Media array conforming to `ObservableObject` and adding a few convenience functions
@objc(MediaLibrary)
public class MediaLibrary: NSManagedObject {
    // We only store a single MediaLibrary in the container, therefore we just use the first result
    static let shared = MediaLibrary.getInstance()
    
    // Don't use a stored property to prevent accessing the viewContext from a background thread (during NSManagedObject creation)
    var libraryContext: NSManagedObjectContext {
        assert(managedObjectContext != nil)
        return self.managedObjectContext ?? PersistenceController.viewContext
    }
    
    private static func getInstance() -> MediaLibrary {
        let results = try? PersistenceController.viewContext.fetch(Self.fetchRequest())
        if let storedLibrary = results?.first as? MediaLibrary {
            return storedLibrary
        }
        // If there is no library stored, we create a new one
        let newLibrary = MediaLibrary(context: PersistenceController.viewContext)
        PersistenceController.saveContext()
        
        return newLibrary
    }
    
    /// Fixes all duplicates IDs by assigning new IDs to the media objects
    @objc
    static func fixDuplicates(notification: Notification) {
        // TODO: Fix duplicate TMDB IDs
        // New data has just been merged from iCloud. Check for duplicate Media IDs
        // TODO: Does passing the context like this work?
        // swiftlint:disable:next force_cast
        let context = notification.object as! NSManagedObjectContext
        let allMedia = Utils.allMedias(context: context)
        let grouped = Dictionary(grouping: allMedia, by: \.id)
        for group in grouped.values {
            // If there is only one item in the group, there are no duplicates
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
    
    func mediaExists(_ tmdbID: Int, in context: NSManagedObjectContext) -> Bool {
        let existingFetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        existingFetchRequest.predicate = NSPredicate(format: "%K = %d", "tmdbID", tmdbID)
        existingFetchRequest.fetchLimit = 1
        let existingObjects: Int
        do {
            existingObjects = try context.count(for: existingFetchRequest)
        } catch {
            assertionFailure("Error fetching media count for tmdbID '\(tmdbID)': \(error)")
            existingObjects = 0
        }
        return existingObjects > 0
    }
    
    func addMedia(_ result: TMDBSearchResult, isLoading: Binding<Bool>, isShowingProPopup: Binding<Bool>) async throws {
        assert(self.managedObjectContext != nil)
        // There should be no media objects with this tmdbID in the library
        guard !self.mediaExists(result.id, in: managedObjectContext!) else {
            // Already added
            AlertHandler.showSimpleAlert(
                title: NSLocalizedString("Already Added"),
                message: NSLocalizedString("You already have '\(result.title)' in your library.")
            )
            return
        }
        // Pro limitations
        guard Utils.purchasedPro() || (self.mediaCount() ?? 0) < JFLiterals.nonProMediaLimit else {
            // Show the Pro popup
            await MainActor.run {
                isShowingProPopup.wrappedValue = true
            }
            return
        }
        
        // Otherwise we can begin to load
        await MainActor.run {
            isLoading.wrappedValue = true
        }
        
        // Run async
        // Try fetching the media object
        // Will be called on a background thread automatically, because TMDBAPI is an actor
        let media = try await TMDBAPI.shared.fetchMedia(
            for: result.id,
            type: result.mediaType,
            context: managedObjectContext!
        )
        // fetchMedia already created the Media object in a child context and saved it into the view context
        // All we need to do now is to load the thumbnail and update the UI
        await MainActor.run {
            if let mainMedia = self.managedObjectContext?.object(with: media.objectID) as? Media {
                // We don't need to wait for the thumbnail to finish loading
                Task {
                    // Call it on the media object in the viewContext, not on the mediaObject in the background context
                    await mainMedia.loadThumbnail()
                }
            } else {
                assertionFailure("Media object does not exist in the viewContext yet. Cannot load thumbnail.")
            }
            isLoading.wrappedValue = false
        }
    }
    
    /// Updates the media library by updaing every media object with API calls again.
    func update() async throws -> Int {
        // Fetch the tmdbIDs of the media objects that changed
        let changedIDs = try await TMDBAPI.shared.fetchChangedIDs(from: lastUpdated, to: Date())
        
        // Create a child context to update the media objects in
        let updateContext = self.libraryContext.newBackgroundContext()
        updateContext.name = "Update Context (\(updateContext.name ?? "unknown"))"
        
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K IN %@", "tmdbID", changedIDs)
        let medias = try self.libraryContext.fetch(fetchRequest)
        print("Updating \(medias.count) media objects.")
        
        // Update the media objects using a task group
        var updateCount = 0
        try await withThrowingTaskGroup(of: Void.self) { group in
            for media in medias {
                _ = group.addTaskUnlessCancelled {
                    // Update the media inside the update context
                    // TODO: Regularly update all thumbnails in the library
                    // TODO: Updating should invalidate the thumbnail (has to be loaded on the main view context again)
                    try await TMDBAPI.shared.updateMedia(media, context: updateContext)
                }
            }
            // Count how many medias were updated and wait for all of them to finish
            for try await _ in group {
                updateCount += 1
            }
        }
        // After they all have been updated without errors, we can update the lastUpdate property
        self.lastUpdated = .now
        // Save the updated media into the parent context (viewContext)
        await PersistenceController.saveContext(updateContext)
        return updateCount
    }
    
    /// Reloads all media objects in the library by re-fetching their TMDBData
    /// - Parameter completion: A closure that will be executed when the reload has finished, providing the last occurred error
    func reloadAll() async throws {
        assert(self.managedObjectContext != nil)
        // Create a new child context to perform the reload in
        let reloadContext = self.libraryContext.newBackgroundContext()
        reloadContext.name = "Reload Context (\(reloadContext.name ?? "unknown"))"
        
        // Fetch all media objects from the store (using the reload context)
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        let medias = (try? reloadContext.fetch(fetchRequest)) ?? []
        print("Reloading \(medias.count) media objects.")
        
        // Reload all media objects using a task group
        try await withThrowingTaskGroup(of: Void.self) { group in
            for media in medias {
                _ = group.addTaskUnlessCancelled {
                    try await TMDBAPI.shared.updateMedia(media, context: reloadContext)
                }
            }
            // Wait for all tasks to finish updating the media objects and rethrow any errors
            try await group.waitForAll()
            // Save the reloaded media into the parent context (viewContext)
            await PersistenceController.saveContext(reloadContext)
            // Reload the thumbnails of all updated media objects in the main context
            for media in medias {
                _ = group.addTaskUnlessCancelled {
                    let mainMedia = await self.libraryContext.perform {
                        self.libraryContext.object(with: media.objectID) as? Media
                    }
                    try Task.checkCancellation()
                    await mainMedia?.loadThumbnail(force: true)
                }
            }
            // We don't need to wait for all the thumbnails to finish loading, we can just exit here
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
        // TODO: Make async
        PersistenceController.saveContext(libraryContext)
    }
    
    func mediaCount() -> Int? {
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        return try? self.managedObjectContext?.count(for: fetchRequest)
    }
}
