// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Resolves source rows into ranked TMDB candidates using bounded concurrency and progressive fallbacks.
struct TitleImportResolver: Sendable {
    private let cache: TitleImportRequestCache
    private let scorer = TitleImportScorer()
    private let workerCount: Int

    /// Creates a resolver with an import-scoped request cache and bounded worker count.
    /// - Parameters:
    ///   - provider: The provider used for TMDB search and detail requests.
    ///   - workerCount: The maximum number of source rows resolved concurrently.
    init(provider: any TitleImportTMDBProviding = TMDBAPI.shared, workerCount: Int = 6) {
        self.cache = TitleImportRequestCache(provider: provider)
        self.workerCount = max(1, workerCount)
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
        return resolved.compactMap { $0 }
    }

    /// Resolves one source row through search variants, optional enrichment, and page-two fallback.
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
            if needsDetails(scored, source: source) {
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

            if
                !isConfident(scored.map(\.candidate), for: source),
                let pageTwo = try? await cache.search(source.title, page: 2)
            {
                // Page two is a final fallback for weak page-one results, not part of every lookup.
                for candidate in pageTwo { candidatesByIdentity[candidate.identity] = candidate }
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

    /// Determines whether candidate enrichment could improve confidence or requested metadata evidence.
    /// - Parameters:
    ///   - scored: The currently ranked candidates.
    ///   - source: The source row supplying optional director and runtime hints.
    /// - Returns: Whether leading candidates should receive detail requests.
    private func needsDetails(
        _ scored: [TitleImportScoredCandidate],
        source: TitleImportSourceRow
    ) -> Bool {
        guard let best = scored.first else { return false }
        let margin = best.score - (scored.dropFirst().first?.score ?? 0)
        return best.score < 75 || margin < 10 || !source.directors.isEmpty || source.runtimeMinutes != nil
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
            status: status,
            reason: reason,
            evidence: TitleImportMatchEvidence(),
            isIncluded: false
        )
    }
}
