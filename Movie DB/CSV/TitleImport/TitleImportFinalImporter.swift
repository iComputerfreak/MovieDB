// Copyright © 2026 Jonas Frey. All rights reserved.

import CoreData
import Foundation

struct TitleImportFinalImporter {
    private let provider: any TitleImportMediaProviding
    private let writerContext: NSManagedObjectContext
    private let batchSize: Int

    init(
        provider: any TitleImportMediaProviding = TMDBAPI.shared,
        writerContext: NSManagedObjectContext = PersistenceController.shared.newBackgroundContext(),
        batchSize: Int = 10
    ) {
        self.provider = provider
        self.writerContext = writerContext
        self.batchSize = max(1, batchSize)
    }

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

            if pendingIdentities.count >= batchSize {
                await flush(&pendingIdentities, into: &result)
            }
            await onProgress(index + 1)
        }

        await flush(&pendingIdentities, into: &result)
        return result
    }

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

    private func limitReached(_ limit: Int?, pendingCount: Int) async throws -> Bool {
        guard let limit else { return false }
        return try await writerContext.perform {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Media")
            request.includesPendingChanges = false
            return try writerContext.count(for: request) + pendingCount >= limit
        }
    }

    private func makeChildContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = writerContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        context.undoManager = nil
        context.type = .backgroundContext
        context.transactionAuthor = appTransactionAuthorName
        return context
    }

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
