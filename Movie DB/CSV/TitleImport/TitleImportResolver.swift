// Copyright © 2026 Jonas Frey. All rights reserved.

#if os(iOS)
import BackgroundTasks
#endif
import Foundation
import OSLog

/// Resolves source rows into ranked TMDB candidates using bounded concurrency and progressive fallbacks.
struct TitleImportResolver: Sendable {
    // swiftlint:disable:previous type_body_length

    /// Carries resolution values and errors through the nonthrowing scheduler coordinator.
    private typealias ResolutionOutcome = Result<[TitleImportReviewItem], any Error>

    private let cache: TitleImportRequestCache
    private let scorer = TitleImportScorer()
    private let workerCount: Int
    private let usesBackgroundContinuation: Bool

    /// Creates a resolver with an import-scoped request cache and bounded worker count.
    /// - Parameters:
    ///   - provider: The provider used for TMDB search and detail requests.
    ///   - workerCount: The maximum number of source rows resolved concurrently.
    ///   - usesBackgroundContinuation: Whether resolution uses continued background processing on supported systems.
    ///   - persistentCache: A durable cache override, primarily used to isolate tests.
    init(
        provider: any TitleImportTMDBProviding = TMDBAPI.shared,
        workerCount: Int = 6,
        usesBackgroundContinuation: Bool = true,
        persistentCache: TitleImportPersistentRequestCache? = nil
    ) {
        let usesDefaultProvider = provider is TMDBAPI
        let persistentCache = persistentCache ?? (usesDefaultProvider ? .shared : nil)
        self.cache = TitleImportRequestCache(
            provider: provider,
            persistentCache: persistentCache
        )
        self.workerCount = max(1, workerCount)
        self.usesBackgroundContinuation = usesBackgroundContinuation
    }

    /// Starts resolution with continued background processing when available.
    /// - Parameters:
    ///   - rows: The normalized source rows to resolve.
    ///   - onProgress: A main-actor callback receiving the number of completed rows.
    /// - Returns: One review item per source row in original order.
    /// - Throws: A resolution error or `CancellationError` when resolution is cancelled.
    func startResolution(
        _ rows: [TitleImportSourceRow],
        onProgress: @MainActor @escaping (Int) -> Void
    ) async throws -> [TitleImportReviewItem] {
        #if os(iOS)
        guard #available(iOS 26.0, *), usesBackgroundContinuation else {
            return try await resolve(rows, onProgress: onProgress)
        }

        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "de.JonasFrey.Movie-DB"
        let taskIdentifier = "\(bundleIdentifier).import.matching.\(UUID().uuidString)"
        let scheduler = BGTaskScheduler.shared
        let coordinator = TitleImportTaskCoordinator(
            taskIdentifier: taskIdentifier,
            cancellationOutcome: ResolutionOutcome.failure(CancellationError()),
            scheduler: scheduler
        )
        let request = BGContinuedProcessingTaskRequest(
            identifier: taskIdentifier,
            title: Strings.TitleImport.title,
            subtitle: Strings.TitleImport.Progress.resolving(0, rows.count)
        )

        let outcome = await withTaskCancellationHandler {
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
                        await resolutionOutcome(rows, task: task, onProgress: onProgress)
                    }
                }

                guard didRegister else {
                    Logger.importExport.error("Could not register continued task for title matching.")
                    coordinator.start(backgroundTask: nil) {
                        await resolutionOutcome(rows, onProgress: onProgress)
                    }
                    return
                }

                do {
                    try coordinator.submit(request)
                } catch {
                    Logger.importExport.error("Error submitting continued task for title matching: \(error)")
                    coordinator.start(backgroundTask: nil) {
                        await resolutionOutcome(rows, onProgress: onProgress)
                    }
                }
            }
        } onCancel: {
            coordinator.cancel()
        }

        return try outcome.get()
        #else
        return try await resolve(rows, onProgress: onProgress)
        #endif
    }

    /// Resolves source rows while preserving source order and reporting throttled progress on the main actor.
    /// - Parameters:
    ///   - rows: The normalized source rows to resolve.
    ///   - onProgress: A main-actor callback receiving the number of completed rows.
    /// - Returns: One review item per source row in original order.
    /// - Throws: `CancellationError` when resolution is cancelled.
    func resolve(
        _ rows: [TitleImportSourceRow],
        onProgress: @MainActor @escaping (Int) -> Void
    ) async throws -> [TitleImportReviewItem] {
        guard !rows.isEmpty else { return [] }
        var resolved = [TitleImportReviewItem?](repeating: nil, count: rows.count)
        var nextIndex = 0
        var completed = 0
        var lastProgressUpdate = ContinuousClock.now

        // Maintain a fixed-size rolling task group so large imports cannot enqueue thousands of network tasks.
        do {
            try await withThrowingTaskGroup(of: (Int, TitleImportReviewItem).self) { group in
                for _ in 0..<min(workerCount, rows.count) {
                    let index = nextIndex
                    nextIndex += 1
                    group.addTask { (index, try await resolve(rows[index])) }
                }

                while let (index, item) = try await group.next() {
                    resolved[index] = item
                    completed += 1
                    let now = ContinuousClock.now
                    if completed == rows.count || lastProgressUpdate.duration(to: now) >= .milliseconds(200) {
                        await onProgress(completed)
                        lastProgressUpdate = now
                    }

                    if nextIndex < rows.count {
                        let index = nextIndex
                        nextIndex += 1
                        group.addTask { (index, try await resolve(rows[index])) }
                    }
                }
            }
        } catch is CancellationError {
            await cache.cancelAll()
            await cache.persist()
            throw CancellationError()
        } catch {
            await cache.persist()
            throw error
        }
        await cache.persist()
        return resolved.compactMap { $0 }
    }

    #if os(iOS)
    /// Resolves rows and converts throwing completion into a scheduler-safe outcome.
    /// - Parameters:
    ///   - rows: The normalized source rows to resolve.
    ///   - task: The continued-processing task receiving progress, or `nil` for foreground fallback.
    ///   - onProgress: A main-actor callback receiving the number of completed rows.
    /// - Returns: The completed rows or encountered error.
    @available(iOS 26.0, *)
    private func resolutionOutcome(
        _ rows: [TitleImportSourceRow],
        task: BGContinuedProcessingTask? = nil,
        onProgress: @MainActor @escaping (Int) -> Void
    ) async -> ResolutionOutcome {
        task?.progress.totalUnitCount = Int64(rows.count)
        do {
            let items = try await resolve(rows) { completedCount in
                task?.progress.completedUnitCount = Int64(completedCount)
                task?.updateTitle(
                    Strings.TitleImport.title,
                    subtitle: Strings.TitleImport.Progress.resolving(completedCount, rows.count)
                )
                onProgress(completedCount)
            }
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
    #endif

    /// Resolves one source row through page-one search variants and optional enrichment.
    /// - Parameter source: The source row to resolve.
    /// - Returns: An accepted, ambiguous, unmatched, or failed review item.
    /// - Throws: `CancellationError` when resolution is cancelled; operational failures become failed review items.
    private func resolve(_ source: TitleImportSourceRow) async throws -> TitleImportReviewItem {
        do {
            // Accumulate candidates from progressively broader queries without duplicating identities.
            var candidatesByIdentity: [MediaIdentity: TitleImportCandidate] = [:]
            let variants = TitleImportTitleMatcher.variants(for: source.title)
            // Search broader variants only until current candidates provide a confident match.
            for (index, query) in variants.enumerated() {
                if index > 0, isConfident(Array(candidatesByIdentity.values), for: source) { break }
                for candidate in try await cache.search(query) {
                    candidatesByIdentity[candidate.identity] = candidate
                }
            }

            guard !candidatesByIdentity.isEmpty else {
                return reviewItem(source: source, status: .noMatch, reason: Strings.TitleImport.Match.noResults)
            }

            // Enrich only when initial evidence cannot classify the leading candidate safely.
            var scored = score(Array(candidatesByIdentity.values), for: source)
            if needsDetails(scored) {
                // Enrich only leading candidates because details require a separate TMDB request per identity.
                for scoredCandidate in scored.prefix(3) {
                    do {
                        let details = try await cache.details(for: scoredCandidate.candidate.identity)
                        var candidate = scoredCandidate.candidate
                        candidate.alternativeTitles = details.alternativeTitles
                        candidate.directors = details.directors
                        candidate.runtimeMinutes = details.runtimeMinutes
                        candidatesByIdentity[candidate.identity] = candidate
                    } catch is CancellationError {
                        throw CancellationError()
                    } catch {
                        continue
                    }
                }
                scored = score(Array(candidatesByIdentity.values), for: source)
            }

            // Require both absolute confidence and separation from the runner-up before auto-inclusion.
            guard let best = scored.first else {
                return reviewItem(source: source, status: .noMatch, reason: Strings.TitleImport.Match.noResults)
            }
            let margin = best.score - (scored.dropFirst().first?.score ?? 0)
            let accepted = best.score >= 75 && margin >= 10 &&
                (best.evidence.titleMatch || best.evidence.alternativeTitleMatch)
            return TitleImportReviewItem(
                id: source.id,
                source: source,
                candidate: best.candidate,
                score: best.score,
                runnerUpScore: scored.dropFirst().first?.score,
                status: accepted ? .accepted : .ambiguous,
                reason: accepted ? Strings.TitleImport.Match.accepted : Strings.TitleImport.Match.ambiguous,
                evidence: best.evidence,
                isIncluded: accepted
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return reviewItem(source: source, status: .failed, reason: error.localizedDescription)
        }
    }

    /// Scores and sorts candidates, using popularity only to break equal scores.
    /// - Parameters:
    ///   - candidates: The unique candidates to rank.
    ///   - source: The source row supplying matching evidence.
    /// - Returns: Candidates ordered from strongest to weakest match.
    private func score(
        _ candidates: [TitleImportCandidate],
        for source: TitleImportSourceRow
    ) -> [TitleImportScoredCandidate] {
        candidates
            .map { scorer.score($0, for: source) }
            .sorted { left, right in
                if left.score == right.score { return left.candidate.popularity > right.candidate.popularity }
                return left.score > right.score
            }
    }

    /// Determines whether current candidates are strong enough to stop broader searching.
    /// - Parameters:
    ///   - candidates: The candidates collected so far.
    ///   - source: The source row supplying matching evidence.
    /// - Returns: Whether the leading title match meets score and margin thresholds.
    private func isConfident(_ candidates: [TitleImportCandidate], for source: TitleImportSourceRow) -> Bool {
        let scored = score(candidates, for: source)
        guard let best = scored.first else { return false }
        let margin = best.score - (scored.dropFirst().first?.score ?? 0)
        return best.score >= 75 && margin >= 10 && best.evidence.titleMatch
    }

    /// Determines whether candidate enrichment could improve an uncertain match.
    /// - Parameter scored: The currently ranked candidates.
    /// - Returns: Whether leading candidates should receive detail requests.
    private func needsDetails(_ scored: [TitleImportScoredCandidate]) -> Bool {
        guard let best = scored.first else { return false }
        let margin = best.score - (scored.dropFirst().first?.score ?? 0)
        return best.score < 75 || margin < 10
    }

    /// Creates a review item without a candidate for unmatched or operationally failed rows.
    /// - Parameters:
    ///   - source: The source row represented by the item.
    ///   - status: The terminal review status.
    ///   - reason: The localized explanation displayed to the user.
    /// - Returns: A locked, excluded review item without matching evidence.
    private func reviewItem(
        source: TitleImportSourceRow,
        status: TitleImportReviewStatus,
        reason: String
    ) -> TitleImportReviewItem {
        TitleImportReviewItem(
            id: source.id,
            source: source,
            candidate: nil,
            score: nil,
            runnerUpScore: nil,
            status: status,
            reason: reason,
            evidence: TitleImportMatchEvidence(),
            isIncluded: false
        )
    }
}
