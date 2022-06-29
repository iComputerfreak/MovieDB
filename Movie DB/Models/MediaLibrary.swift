//
//  MediaLibrary.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
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
    func addMedia(_ result: TMDBSearchResult, isLoading: Binding<Bool>) async throws {
        // There should be no media objects with this tmdbID in the library
        guard !mediaExists(result.id, in: context) else {
            throw UserError.mediaAlreadyAdded
        }
        // Pro limitations
        guard Utils.purchasedPro() || (mediaCount() ?? 0) < JFLiterals.nonProMediaLimit else {
            throw UserError.noPro
        }
        
        // Otherwise we can begin to load
        await MainActor.run {
            isLoading.wrappedValue = true
        }
        
        // Run async
        // Try fetching the media object
        // Will be called on a background thread automatically, because TMDBAPI is an actor
        // We don't need to store the result. Creating it is enough for Core Data
        _ = try await TMDBAPI.shared.media(
            for: result.id,
            type: result.mediaType,
            context: context
        )
        await PersistenceController.saveContext(context)
        // fetchMedia already created the Media object in a child context and saved it into the view context
        // All we need to do now is to load the thumbnail and update the UI
        await MainActor.run {
            isLoading.wrappedValue = false
        }
    }
    
    /// Updates the media library by updaing every media object with API calls again.
    func update() async throws -> Int {
        // Fetch the tmdbIDs of the media objects that changed
        let changedIDs = try await TMDBAPI.shared.changedIDs(from: lastUpdated, to: Date())
        
        // Create a child context to update the media objects in
        let updateContext = context.newBackgroundContext()
        updateContext.name = "Update Context (\(updateContext.name ?? "unknown"))"
        
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K IN %@", "tmdbID", changedIDs)
        let medias = try context.fetch(fetchRequest)
        print("Updating \(medias.count) media objects.")
        
        // Update the media objects using a task group
        var updateCount = 0
        try await withThrowingTaskGroup(of: Void.self) { group in
            for media in medias {
                _ = group.addTaskUnlessCancelled {
                    // Update the media inside the update context (including the thumbnail)
                    try await TMDBAPI.shared.updateMedia(media, context: updateContext)
                }
            }
            // Count how many medias were updated and wait for all of them to finish
            for try await _ in group {
                updateCount += 1
            }
        }
        // After they all have been updated without errors, we can update the lastUpdate property
        lastUpdated = .now
        // Save the updated media into the parent context (viewContext)
        await PersistenceController.saveContext(updateContext)
        return updateCount
    }
    
    /// Reloads all media objects in the library by re-fetching their TMDBData
    /// - Parameter completion: A closure that will be executed when the reload has finished, providing the last occurred error
    func reloadAll() async throws {
        // Create a new child context to perform the reload in
        let reloadContext = context.newBackgroundContext()
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
    
    /// Resets the library, deleting everything!
    func reset() throws {
        try PersistenceController.shared.reset()
        // Delete images
        if let imagesDirectory = Utils.imagesDirectory() {
            try FileManager.default.removeItem(at: imagesDirectory)
        }
    }
    
    /// Performs a cleanup of the library, deleting all entities with missing relations (e.g. unused ``Genre``s or ``ProductionCompany``s
    func cleanup() throws {
        try delete(
            Genre.entity().name!,
            predicate: NSPredicate(format: "medias.@count = 0")
        )
        try delete(
            ProductionCompany.entity().name!,
            predicate: NSPredicate(format: "medias.@count = 0 AND shows.@count = 0")
        )
        try delete(
            Video.entity().name!,
            predicate: NSPredicate(format: "media = nil")
        )
        try delete(
            Season.entity().name!,
            predicate: NSPredicate(format: "show = nil")
        )
    }
    
    private func delete(_ entityName: String, predicate: NSPredicate) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetch.predicate = predicate
        let delete = NSBatchDeleteRequest(fetchRequest: fetch)
        try context.execute(delete)
    }
    
    /// Resets all available tags and their relation to the media objects
    func resetTags() async throws {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let allTags = (try? context.fetch(fetchRequest)) ?? []
        for tag in allTags {
            // Tag will be automatically removed from all medias
            context.delete(tag)
        }
        await PersistenceController.saveContext(context)
    }
    
    func mediaCount() -> Int? {
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        return try? context.count(for: fetchRequest)
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
