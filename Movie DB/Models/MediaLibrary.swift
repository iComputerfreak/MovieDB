//
//  MediaLibrary.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

struct MediaLibrary {
    static let shared = MediaLibrary(context: PersistenceController.viewContext)
    
    let context: NSManagedObjectContext
    @AppStorage("lastLibraryUpdate") var lastUpdated: Date = .now
    
    /// Returns all library problems that need to be resolved by the user
    func problems() -> [Problem] {
        var problems: [Problem] = []
        let allMedia = Utils.allMedias(context: context)
        Dictionary(grouping: allMedia, by: \.tmdbID)
            .values
            // Only keep duplicates
            .filter { $0.count > 1 }
            // Create a problem for each duplicate
            .forEach { problems.append(.init(type: .duplicateMedia, associatedMedias: $0)) }
        return problems
    }
    
    /// Checks whether a media object matching the given tmdbID already exists in the given context
    /// - Parameters:
    ///   - tmdbID: The tmdbID of the media
    ///   - context: The context to check in
    /// - Returns: Whether the media already exists
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
    
    /// Creates a new media object with the given data
    /// - Parameters:
    ///   - result: The search result including the tmdbID and mediaType
    ///   - isLoading: A binding that is updated while the function is loading the new object
    ///   - isShowingProPopup: A binding that is updated when the adding failed due to the user not having bought pro
    // TODO: Replace second binding with custom error (noPro)
    func addMedia(_ result: TMDBSearchResult, isLoading: Binding<Bool>, isShowingProPopup: Binding<Bool>) async throws {
        // There should be no media objects with this tmdbID in the library
        guard !self.mediaExists(result.id, in: context) else {
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
        let media = try await TMDBAPI.shared.media(
            for: result.id,
            type: result.mediaType,
            context: context
        )
        // fetchMedia already created the Media object in a child context and saved it into the view context
        // All we need to do now is to load the thumbnail and update the UI
        await MainActor.run {
            if let mainMedia = self.context.object(with: media.objectID) as? Media {
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
        let changedIDs = try await TMDBAPI.shared.changedIDs(from: lastUpdated, to: Date())
        
        // Create a child context to update the media objects in
        let updateContext = self.context.newBackgroundContext()
        updateContext.name = "Update Context (\(updateContext.name ?? "unknown"))"
        
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K IN %@", "tmdbID", changedIDs)
        let medias = try self.context.fetch(fetchRequest)
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
        // Create a new child context to perform the reload in
        let reloadContext = self.context.newBackgroundContext()
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
                    let mainMedia = await self.context.perform {
                        self.context.object(with: media.objectID) as? Media
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
        let allMedias = (try? context.fetch(fetchRequest)) ?? []
        for media in allMedias {
            context.delete(media)
            // Thumbnail and Video objects will be automatically deleted by the cascading delete rule
        }
        // Reset the ID counter for the media objects
        // TODO: Make async
        PersistenceController.saveContext(context)
    }
    
    func mediaCount() -> Int? {
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        return try? self.context.count(for: fetchRequest)
    }
}

extension Date: RawRepresentable {
    public typealias RawValue = String
    
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Self.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        if let date = Self.formatter.date(from: rawValue) {
            self = date
        }
        return nil
    }
}
