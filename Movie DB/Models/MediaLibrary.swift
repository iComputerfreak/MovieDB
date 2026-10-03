// Copyright © 2022 Jonas Frey. All rights reserved.

import CoreData
import Foundation
import os.log
import SwiftUI

// swiftlint:disable:next type_body_length
struct MediaLibrary {
    static let shared = Self(context: PersistenceController.viewContext)
    
    let context: NSManagedObjectContext
    
    @AppStorage(JFLiterals.Keys.lastLibraryUpdate)
    var lastUpdated: TimeInterval = Date.now.timeIntervalSince1970

    /// Returns all library problems that need to be resolved by the user
    func problems() -> [Problem] {
        var problems: [Problem] = []
        
        // Only fetch medias from the store that are actually duplicates.
        // This prevents fetching all medias here and therefore starting all media thumbnail download tasks
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Media")

        // We need the result to include the count in order to only fetch duplicates
        let mediaTypeProperty = Schema.Media.type.rawValue
        let tmdbIDProperty = Schema.Media.tmdbID.rawValue
        let tmdbIDExpr = NSExpression(forKeyPath: tmdbIDProperty)
        let countExpr = NSExpressionDescription()
        let countVariableExpr = NSExpression(forVariable: "count")
        
        countExpr.name = "count"
        countExpr.expression = NSExpression(forFunction: "count:", arguments: [tmdbIDExpr])
        countExpr.expressionResultType = .integer64AttributeType

        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToGroupBy = [tmdbIDProperty, mediaTypeProperty]
        fetchRequest.propertiesToFetch = [mediaTypeProperty, tmdbIDProperty, "objectID", countExpr]

        // Only return results that have duplicates
        fetchRequest.havingPredicate = NSPredicate(format: "%@ > 1", countVariableExpr)
        
        do {
            if
                let results = try context.fetch(fetchRequest) as? [[String: Any]],
                !results.isEmpty
            {
                // Fetch all duplicate IDs
                let duplicateIDs = results.compactMap { $0[tmdbIDProperty] }
                let duplicateRequest = Media.fetchRequest()
                duplicateRequest.predicate = NSPredicate(format: "%K IN %@", tmdbIDProperty, duplicateIDs)
                let duplicateMedias = try context.fetch(duplicateRequest)
                // Group all duplicate medias by tmdbID
                Dictionary(grouping: duplicateMedias, by: { "\($0.type).\($0.tmdbID)" })
                    // We don't care about the key
                    .values
                    // Filter out false positives (identical TMDB ID, but different media type)
                    .filter { $0.count > 1 }
                    // Add all duplicate arrays to the problems list
                    .forEach { duplicates in
                        problems.append(.init(type: .duplicateMedia, associatedMedias: duplicates))
                    }
                return problems
            }
        } catch {
            Logger.coreData.error("Error fetching duplicate medias: \(error, privacy: .public)")
        }
        
        return []
    }
    
    func media(for tmdbID: Int, mediaType: MediaType, in context: NSManagedObjectContext) throws -> Media? {
        let fetchRequest = Media.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K = %d AND %K = %@",
            Schema.Media.tmdbID,
            tmdbID,
            Schema.Media.type,
            mediaType.rawValue
        )
        fetchRequest.fetchLimit = 1
        return try context.fetch(fetchRequest).first
    }
    
    /// Checks whether a media object matching the given tmdbID already exists in the given context
    /// - Parameters:
    ///   - tmdbID: The tmdbID of the media
    ///   - context: The context to check in
    /// - Returns: Whether the media already exists
    func mediaExists(_ tmdbID: Int, mediaType: MediaType, in context: NSManagedObjectContext? = nil) -> Bool {
        return (try? media(for: tmdbID, mediaType: mediaType, in: context ?? self.context)) != nil
    }
    
    /// Creates a new media object with the given data
    /// - Parameters:
    ///   - result: The search result including the tmdbID and mediaType
    ///   - isLoading: A binding that is updated while the function is loading the new object
    func addMedia(_ result: TMDBSearchResult) async throws {
        try await addMedia(tmdbID: result.id, mediaType: result.mediaType)
    }
    
    /// Creates a new media object with the given data
    /// - Parameters:
    ///   - tmdbID: The ID on themoviedb.org
    ///   - mediaType: The type of media
    ///   - isLoading: A binding that is updated while the function is loading the new object
    func addMedia(tmdbID: Int, mediaType: MediaType) async throws {
        Logger.addMedia.debug("Trying to add media \(tmdbID) with type \(mediaType.rawValue)...")
        // There should be no media objects with this tmdbID in the library
        guard !mediaExists(tmdbID, mediaType: mediaType, in: context) else {
            throw UserError.mediaAlreadyAdded
        }
        // Pro limitations
        guard StoreManager.shared.hasPurchasedPro || (mediaCount() ?? 0) < JFLiterals.nonProMediaLimit else {
            throw UserError.noPro
        }
        
        // Run async
        // Try fetching the media object
        // Will be called on a background thread automatically, because TMDBAPI is an actor
        // We don't need to store the result. Creating it is enough for Core Data
        _ = try await TMDBAPI.shared.media(
            for: tmdbID,
            type: mediaType,
            context: context
        )
        await PersistenceController.saveContext(context)
        // fetchMedia already created the Media object in a child context and saved it into the view context
        // All we need to do now is to load the thumbnail and update the UI
    }
    
    /// Updates the media library by updaing every media object with API calls again.
    func update() async throws -> Int {
        // Fetch the tmdbIDs of the media objects that changed
        let lastUpdate = Date(timeIntervalSince1970: lastUpdated)
        let changedIDs = try await TMDBAPI.shared.changedIDs(from: lastUpdate, to: Date.now)
        
        // Use a store-backed context so each completed update persists independently.
        let updateContext = PersistenceController.shared.newBackgroundContext()
        
        var mediaIDs: [NSManagedObjectID] = []
        for type in changedIDs.keys {
            let typeChangedIDs = changedIDs[type] ?? []
            let fetchedIDs = try await context.perform {
                let fetchRequest: NSFetchRequest<Media> = switch type {
                case .movie: Movie.fetchRequest()
                case .show: Show.fetchRequest()
                }
                fetchRequest.predicate = NSPredicate(
                    format: "type = %@ AND tmdbID IN %@",
                    type.rawValue,
                    typeChangedIDs
                )
                return try context.fetch(fetchRequest).map(\.objectID)
            }
            mediaIDs.append(contentsOf: fetchedIDs)
        }
        Logger.library.info("Updating \(mediaIDs.count) media objects.")

        let updateID = await LibraryUpdateStatus.shared.begin(origin: .manualUpdate, total: mediaIDs.count)

        // Update the media objects using a task group
        var updateCount = 0
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for mediaID in mediaIDs {
                    _ = group.addTaskUnlessCancelled {
                        // Update the media inside the update context (including the thumbnail)
                        try await TMDBAPI.shared.updateMedia(mediaID, context: updateContext)
                        await LibraryUpdateStatus.shared.increment(updateID)
                    }
                }
                // Count how many medias were updated and wait for all of them to finish
                for try await _ in group {
                    updateCount += 1
                }
            }
        } catch {
            await LibraryUpdateStatus.shared.finish(updateID)
            throw error
        }
        // After they all have been updated without errors, we can update the lastUpdate property
        lastUpdated = Date.now.timeIntervalSince1970
        // Save the updated media into the parent context (viewContext)
        await PersistenceController.saveContext(updateContext)
        // Save the view context to make the changes persistent
        await PersistenceController.saveContext(context)
        await LibraryUpdateStatus.shared.finish(updateID)
        return updateCount
    }
    
    /// Reloads all media objects in the library by re-fetching their TMDB data.
    /// - Parameters:
    ///   - fromBackground: Whether thumbnail downloads should finish before this function returns.
    ///   - origin: Source of the reload, used to report progress.
    /// - Returns: Number of media objects successfully updated.
    /// - Throws: An error when the reload cannot finish, including `CancellationError` when cancelled.
    @discardableResult
    func reloadAll(fromBackground: Bool = false, origin: LibraryUpdateStatus.Origin) async throws -> Int {
        // Use a store-backed context so each completed update survives background expiration.
        let reloadContext = PersistenceController.shared.newBackgroundContext()
        
        let cutoffDate = Date.now.addingTimeInterval(-7 * .day)
        let mediaIDs = try await reloadContext.perform {
            // Fetch object IDs only; managed objects remain confined to their context queue.
            let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Media.lastUpdated, ascending: true)]
            if fromBackground {
                fetchRequest.predicate = NSPredicate(
                    format: "%K == nil OR %K < %@",
                    Schema.Media.lastUpdated.rawValue,
                    Schema.Media.lastUpdated.rawValue,
                    cutoffDate as NSDate
                )
            }
            return try reloadContext.fetch(fetchRequest).map(\.objectID)
        }
        Logger.library.info("Reloading \(mediaIDs.count) media objects.")

        guard !mediaIDs.isEmpty else {
            lastUpdated = Date.now.timeIntervalSince1970
            return 0
        }

        let reloadID = await LibraryUpdateStatus.shared.begin(origin: origin, total: mediaIDs.count)

        let updatedMediaCount: Int
        do {
            // Reload all media objects while preserving individual request failures.
            updatedMediaCount = try await withThrowingTaskGroup(of: Bool.self) { group in
                for mediaID in mediaIDs {
                    _ = group.addTaskUnlessCancelled {
                        do {
                            try await TMDBAPI.shared.updateMedia(mediaID, context: reloadContext)
                            await LibraryUpdateStatus.shared.increment(reloadID)
                            return true
                        } catch {
                            if Task.isCancelled || error is CancellationError {
                                throw CancellationError()
                            }
                            // swiftlint:disable:next line_length
                            Logger.library.error("Error updating media \(mediaID.uriRepresentation().absoluteString, privacy: .public): \(error, privacy: .public)")
                            await LibraryUpdateStatus.shared.increment(reloadID)
                            return false
                        }
                    }
                }
                var updatedMediaCount = 0
                for try await didUpdate in group where didUpdate {
                    updatedMediaCount += 1
                }
                try Task.checkCancellation()
                return updatedMediaCount
            }
        } catch {
            await LibraryUpdateStatus.shared.finish(reloadID)
            throw error
        }

        try Task.checkCancellation()
        // Save the reloaded media into the parent context (viewContext)
        await PersistenceController.saveContext(reloadContext)
        // Save the view context
        await PersistenceController.saveContext(PersistenceController.viewContext)

        await LibraryUpdateStatus.shared.finish(reloadID)
        // Since we just reloaded all media, they are all up-to-date
        // We also need this, in the case of an invalid set lastUpdated value that prevents the update to work
        lastUpdated = Date.now.timeIntervalSince1970
        PersistenceController.saveContext()
        Logger.library.info("Successfully reloaded \(mediaIDs.count) medias.")
        return updatedMediaCount
    }
    
    /// Resets the library, deleting everything!
    func reset() throws {
        try PersistenceController.shared.reset()
        // Delete images
        try FileManager.default.removeItem(at: Utils.imagesDirectory())
    }
    
    /// Performs a cleanup of the library, deleting unused entities
    func cleanup() throws {
        if context.hasChanges {
            try context.save()
        }

        // MARK: Delete entities that are not used anymore
        Logger.library.info("Deleting unused entities...")
        try delete(
            Schema.Genre._entityName,
            predicate: NSPredicate(format: "medias.@count = 0")
        )
        try delete(
            Schema.ProductionCompany._entityName,
            predicate: NSPredicate(format: "medias.@count = 0 AND shows.@count = 0")
        )
        try delete(
            Schema.Video._entityName,
            predicate: NSPredicate(format: "media = nil")
        )
        try delete(
            Schema.Season._entityName,
            predicate: NSPredicate(format: "show = nil")
        )
    }
    
    private func delete(_ entityName: String, predicate: NSPredicate) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetch.predicate = predicate
        let delete = NSBatchDeleteRequest(fetchRequest: fetch)
        delete.resultType = .resultTypeObjectIDs

        if
            let result = try context.execute(delete) as? NSBatchDeleteResult,
            let objectIDs = result.result as? [NSManagedObjectID],
            !objectIDs.isEmpty
        {
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                into: [context]
            )
        }
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
