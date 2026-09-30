// Copyright © 2026 Jonas Frey. All rights reserved.

import BackgroundTasks
import CoreData
import Foundation
import OSLog

/// Imports resolved identities through disposable child contexts and bounded writer-context batches.
struct TitleImportFinalImporter {
    // swiftlint:disable:previous type_body_length
    private let provider: any TitleImportMediaProviding
    private let writerContext: NSManagedObjectContext
    private let batchSize: Int
    private let usesBackgroundContinuation: Bool

    /// Creates a final importer.
    /// - Parameters:
    ///   - provider: The provider that creates complete media object graphs.
    ///   - writerContext: The context that commits successful child-context batches to persistent storage.
    ///   - batchSize: The maximum number of successfully decoded identities saved per writer batch.
    ///   - usesBackgroundContinuation: Whether imports use continued background processing on supported systems.
    init(
        provider: any TitleImportMediaProviding = TMDBAPI.shared,
        writerContext: NSManagedObjectContext = PersistenceController.shared.newBackgroundContext(),
        batchSize: Int = 10,
        usesBackgroundContinuation: Bool = true
    ) {
        self.provider = provider
        self.writerContext = writerContext
        self.batchSize = max(1, batchSize)
        self.usesBackgroundContinuation = usesBackgroundContinuation
    }

    /// Starts an import with continued background processing when available.
    /// - Parameters:
    ///   - identities: The ordered identities selected for import.
    ///   - libraryLimit: The maximum allowed total library count, or `nil` for no limit.
    ///   - onProgress: A main-actor callback receiving the number of processed identities.
    /// - Returns: A summary of imported, duplicate, failed, and unprocessed identities.
    func startMediaImport( // swiftlint:disable:this function_body_length
        identities: [MediaIdentity],
        libraryLimit: Int?,
        onProgress: @MainActor @escaping (Int) -> Void
    ) async -> TitleImportFinalResult {
        if #available(iOS 26.0, *), usesBackgroundContinuation {
            let bundleIdentifier = Bundle.main.bundleIdentifier ?? "de.JonasFrey.Movie-DB"
            let taskIdentifier = "\(bundleIdentifier).import.\(UUID().uuidString)"
            let scheduler = BGTaskScheduler.shared
            let coordinator = TitleImportTaskCoordinator(
                taskIdentifier: taskIdentifier,
                cancellationOutcome: TitleImportFinalResult(remainingIdentities: identities),
                scheduler: scheduler
            )

            let request = BGContinuedProcessingTaskRequest(
                identifier: taskIdentifier,
                title: Strings.TitleImport.FinalImport.title,
                subtitle: Strings.TitleImport.FinalImport.progress(0, identities.count)
            )

            return await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    guard coordinator.install(continuation) else { return }

                    let didRegister = scheduler.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
                        guard let task = task as? BGContinuedProcessingTask else {
                            task.setTaskCompleted(success: false)
                            coordinator.cancel()
                            return
                        }

                        task.expirationHandler = {
                            coordinator.cancel()
                        }
                        coordinator.start(backgroundTask: task) {
                            await startMediaImportContinuationTask(
                                identities: identities,
                                libraryLimit: libraryLimit,
                                onProgress: onProgress,
                                task: task
                            )
                        }
                    }

                    guard didRegister else {
                        Logger.importExport.error("Could not register continued task for title import.")
                        coordinator.start(backgroundTask: nil) {
                            await importMedia(
                                identities: identities,
                                libraryLimit: libraryLimit,
                                onProgress: onProgress
                            )
                        }
                        return
                    }

                    do {
                        try coordinator.submit(request)
                    } catch {
                        Logger.importExport.error("Error submitting task request for title import: \(error)")
                        coordinator.start(backgroundTask: nil) {
                            await importMedia(
                                identities: identities,
                                libraryLimit: libraryLimit,
                                onProgress: onProgress
                            )
                        }
                    }
                }
            } onCancel: {
                coordinator.cancel()
            }
        } else {
            return await importMedia(identities: identities, libraryLimit: libraryLimit, onProgress: onProgress)
        }
    }

    /// Runs an import while reporting system-visible continued-task progress.
    /// - Parameters:
    ///   - identities: The ordered identities selected for import.
    ///   - libraryLimit: The maximum allowed total library count, or `nil` for no limit.
    ///   - onProgress: A main-actor callback receiving the number of processed identities.
    ///   - task: The continued-processing task protecting the import.
    /// - Returns: A summary of imported, duplicate, failed, and unprocessed identities.
    @available(iOS 26.0, *)
    private func startMediaImportContinuationTask(
        identities: [MediaIdentity],
        libraryLimit: Int?,
        onProgress: @MainActor @escaping (Int) -> Void,
        task: BGContinuedProcessingTask
    ) async -> TitleImportFinalResult {
        task.progress.totalUnitCount = Int64(identities.count)

        return await importMedia(
            identities: identities,
            libraryLimit: libraryLimit
        ) { completedCount in
            task.progress.completedUnitCount = Int64(completedCount)
            task.updateTitle(
                Strings.TitleImport.FinalImport.title,
                subtitle: Strings.TitleImport.FinalImport.progress(completedCount, identities.count)
            )
            onProgress(completedCount)
        }
    }

    /// Imports identities sequentially while preserving completed batches across failures or cancellation.
    /// - Parameters:
    ///   - identities: The ordered identities selected for import.
    ///   - libraryLimit: The maximum allowed total library count, or `nil` for no limit.
    ///   - onProgress: A main-actor callback receiving the number of processed identities.
    /// - Returns: A summary of imported, duplicate, failed, and unprocessed identities.
    private func importMedia(
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
                    result.duplicateIdentities.append(identity)
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
            result.importedIdentities.append(contentsOf: pendingIdentities)
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
