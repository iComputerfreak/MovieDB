// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

struct TitleImportResolver: Sendable {
    private let cache: TitleImportRequestCache
    private let scorer = TitleImportScorer()
    private let workerCount: Int

    init(provider: any TitleImportTMDBProviding = TMDBAPI.shared, workerCount: Int = 6) {
        self.cache = TitleImportRequestCache(provider: provider)
        self.workerCount = max(1, workerCount)
    }

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

    private func resolve(_ source: TitleImportSourceRow) async throws -> TitleImportReviewItem {
        do {
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
                reason: accepted
                    ? Strings.TitleImport.Match.accepted(Int(best.score.rounded()))
                    : Strings.TitleImport.Match.ambiguous(Int(best.score.rounded()), Int(margin.rounded())),
                evidence: best.evidence,
                isIncluded: accepted
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return reviewItem(source: source, status: .failed, reason: error.localizedDescription)
        }
    }

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

    private func isConfident(_ candidates: [TitleImportCandidate], for source: TitleImportSourceRow) -> Bool {
        let scored = score(candidates, for: source)
        guard let best = scored.first else { return false }
        let margin = best.score - (scored.dropFirst().first?.score ?? 0)
        return best.score >= 75 && margin >= 10 && best.evidence.titleMatch
    }

    private func needsDetails(
        _ scored: [TitleImportScoredCandidate],
        source: TitleImportSourceRow
    ) -> Bool {
        guard let best = scored.first else { return false }
        let margin = best.score - (scored.dropFirst().first?.score ?? 0)
        return best.score < 75 || margin < 10 || !source.directors.isEmpty || source.runtimeMinutes != nil
    }

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
