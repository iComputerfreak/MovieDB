// Copyright © 2026 Jonas Frey. All rights reserved.

import CoreData
import Foundation

/// Imports resolved identities through disposable child contexts and bounded writer-context batches.
struct TitleImportFinalImporter {
    private let provider: any TitleImportMediaProviding
    private let writerContext: NSManagedObjectContext
    private let batchSize: Int

    /// Creates a final importer.
    /// - Parameters:
    ///   - provider: The provider that creates complete media object graphs.
    ///   - writerContext: The context that commits successful child-context batches to persistent storage.
    ///   - batchSize: The maximum number of successfully decoded identities saved per writer batch.
    init(
        provider: any TitleImportMediaProviding = TMDBAPI.shared,
        writerContext: NSManagedObjectContext = PersistenceController.shared.newBackgroundContext(),
        batchSize: Int = 10
    ) {
        self.provider = provider
        self.writerContext = writerContext
        self.batchSize = max(1, batchSize)
    }

    /// Imports identities sequentially while preserving completed batches across failures or cancellation.
    /// - Parameters:
    ///   - identities: The ordered identities selected for import.
    ///   - libraryLimit: The maximum allowed total library count, or `nil` for no limit.
    ///   - onProgress: A main-actor callback receiving the number of processed identities.
    /// - Returns: A summary of imported, duplicate, failed, and unprocessed identities.
    func importMedia(
        identities: [MediaIdentity],
        libraryLimit: Int?,
        onProgress: @MainActor @escaping (Int) -> Void
    ) async -> TitleImportFinalResult {
        var result = TitleImportFinalResult()
        var pendingIdentities: [MediaIdentity] = []

        // Each identity gets a disposable child context so a decode failure cannot leak partial objects into a batch.
        for (index, identity) in identities.enumerated() {
            if Task.isCancelled {
                result.remainingIdentities = Array(identities[index...])
                break
            }

            do {
                // Recheck mutable library constraints immediately before creating each object graph.
                if try await limitReached(libraryLimit, pendingCount: pendingIdentities.count) {
                    result.remainingIdentities = Array(identities[index...])
                    break
                }
                let isPending = pendingIdentities.contains(identity)
                let isStored = isPending ? false : try await contains(identity)
                if isPending || isStored {
                    result.duplicateCount += 1
                } else {
                    let childContext = makeChildContext()
                    do {
                        try await provider.titleImportMedia(for: identity, context: childContext)
                        try await childContext.perform { try childContext.save() }
                        pendingIdentities.append(identity)
                    } catch is CancellationError {
                        await childContext.perform { childContext.rollback() }
                        result.remainingIdentities = Array(identities[index...])
                        break
                    } catch {
                        await childContext.perform { childContext.rollback() }
                        result.failedIdentities.append(identity)
                    }
                }
            } catch {
                result.failedIdentities.append(identity)
            }

            // Commit bounded batches so prior successes survive later failures or cancellation.
            if pendingIdentities.count >= batchSize {
                await flush(&pendingIdentities, into: &result)
            }
            await onProgress(index + 1)
        }

        await flush(&pendingIdentities, into: &result)
        return result
    }

    /// Checks persisted storage for an identity, excluding unsaved writer-context changes.
    /// - Parameter identity: The media identity to look up.
    /// - Returns: Whether persistent storage already contains the identity.
    /// - Throws: A Core Data count error when the lookup cannot complete.
    private func contains(_ identity: MediaIdentity) async throws -> Bool {
        try await writerContext.perform {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Media")
            request.predicate = NSPredicate(
                format: "%K = %d AND %K = %@",
                Schema.Media.tmdbID.rawValue,
                identity.tmdbID,
                Schema.Media.type.rawValue,
                identity.type.rawValue
            )
            request.fetchLimit = 1
            // Pending identities are checked in memory to avoid KVC evaluation of computed Core Data accessors.
            request.includesPendingChanges = false
            return try writerContext.count(for: request) > 0
        }
    }

    /// Checks whether persisted and pending objects have reached the active library limit.
    /// - Parameters:
    ///   - limit: The maximum total count, or `nil` for no limit.
    ///   - pendingCount: The number of successfully decoded objects awaiting a writer save.
    /// - Returns: Whether importing another identity would exceed the limit.
    /// - Throws: A Core Data count error when the current library size cannot be read.
    private func limitReached(_ limit: Int?, pendingCount: Int) async throws -> Bool {
        guard let limit else { return false }
        return try await writerContext.perform {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Media")
            request.includesPendingChanges = false
            return try writerContext.count(for: request) + pendingCount >= limit
        }
    }

    /// Creates a disposable private child context whose successful save feeds the writer context.
    /// - Returns: A configured child context for one identity.
    private func makeChildContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = writerContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        context.undoManager = nil
        context.type = .backgroundContext
        context.transactionAuthor = appTransactionAuthorName
        return context
    }

    /// Saves one pending batch or converts the entire batch to failures after rolling back the writer.
    /// - Parameters:
    ///   - pendingIdentities: The identities represented by unsaved writer-context changes.
    ///   - result: The result summary updated with imported or failed identities.
    private func flush(
        _ pendingIdentities: inout [MediaIdentity],
        into result: inout TitleImportFinalResult
    ) async {
        guard !pendingIdentities.isEmpty else { return }
        // Only count a batch after the writer reaches the persistent store; a failed save rolls back the whole batch.
        do {
            try await writerContext.perform {
                try writerContext.save()
                writerContext.reset()
            }
            result.importedCount += pendingIdentities.count
        } catch {
            result.failedIdentities.append(contentsOf: pendingIdentities)
            await writerContext.perform {
                writerContext.rollback()
                writerContext.reset()
            }
        }
        pendingIdentities.removeAll(keepingCapacity: true)
    }
}
