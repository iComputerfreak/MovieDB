// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Scores TMDB candidates against source metadata and records the evidence contributing to each score.
struct TitleImportScorer {
    // swiftlint:disable function_body_length
    /// Scores one candidate using title equivalence, similarity, year, director, runtime, and media type.
    /// - Parameters:
    ///   - candidate: The TMDB candidate to evaluate.
    ///   - source: The normalized source row supplying matching evidence.
    /// - Returns: The candidate's aggregate score and evidence flags.
    func score(_ candidate: TitleImportCandidate, for source: TitleImportSourceRow) -> TitleImportScoredCandidate {
        // Establish title equivalence before adding independent metadata evidence.
        let sourceVariants = TitleImportTitleMatcher.variants(for: source.title)
        let candidateTitles = [candidate.title, candidate.originalTitle] + candidate.alternativeTitles
        let exactYearMatch = source.year != nil && source.year == candidate.year
        let equivalences = candidateTitles.compactMap { candidateTitle in
            TitleImportTitleMatcher.equivalence(
                between: source.title,
                and: candidateTitle,
                exactYearMatch: exactYearMatch
            )
        }
        let normalizedSource = sourceVariants.map(TitleImportTitleMatcher.normalize)
        let normalizedCandidates = candidateTitles.map(TitleImportTitleMatcher.normalize)

        let rawTitle = normalizedSource.first ?? ""
        let rawExact = normalizedCandidates.contains(rawTitle)
        let editionExact = equivalences.contains { $0 == .edition }
        let subtitleExact = equivalences.contains { $0 == .subtitle }
        let containedExact = equivalences.contains { $0 == .contained }
        let variantExact = candidateTitles.contains { candidateTitle in
            matchesSourceVariant(
                candidateTitle,
                sourceTitle: source.title,
                sourceVariants: sourceVariants,
                exactYearMatch: exactYearMatch
            )
        }
        let alternativeExact = candidate.alternativeTitles
            .contains { alternativeTitle in
                let normalized = TitleImportTitleMatcher.normalize(alternativeTitle)
                return normalized == rawTitle || matchesSourceVariant(
                    alternativeTitle,
                    sourceTitle: source.title,
                    sourceVariants: sourceVariants,
                    exactYearMatch: exactYearMatch
                )
            }
        let similarity = sourceVariants.flatMap { sourceTitle in
            candidateTitles.map { TitleImportTitleMatcher.similarity(sourceTitle, $0) }
        }
            .max() ?? 0

        var evidence = TitleImportMatchEvidence()
        evidence.titleMatch = rawExact || editionExact || subtitleExact || containedExact || variantExact
        evidence.alternativeTitleMatch = alternativeExact

        // Exact and safe-equivalence matches establish the base score; fuzzy matches receive less weight.
        var score: Double
        if rawExact {
            score = 75
        } else if editionExact {
            score = 75
        } else if subtitleExact || containedExact {
            score = 66
        } else if variantExact || alternativeExact {
            score = 66
        } else if similarity >= 0.92 {
            score = 54
        } else if similarity >= 0.82 {
            score = 38
        } else if similarity >= 0.7 {
            score = 20
        } else {
            score = 0
        }

        // Corroborating metadata adjusts confidence without overriding a clearly unrelated title.
        if let sourceYear = source.year, let candidateYear = candidate.year {
            switch abs(sourceYear - candidateYear) {
            case 0:
                score += 24
                evidence.yearMatch = true
            case 1:
                score += 14
                evidence.yearMatch = true
            case 2:
                score += 7
            case 3...5:
                score += 1
            default:
                score -= 4
            }
        }

        if !source.directors.isEmpty, !candidate.directors.isEmpty {
            let matches = source.directors.contains { sourceDirector in
                candidate.directors.contains { TitleImportTitleMatcher.peopleMatch(sourceDirector, $0) }
            }
            if matches {
                score += 30
                evidence.directorMatch = true
            } else {
                score -= 8
            }
        }

        if let sourceRuntime = source.runtimeMinutes, let candidateRuntime = candidate.runtimeMinutes {
            switch abs(sourceRuntime - candidateRuntime) {
            case 0...3:
                score += 8
                evidence.runtimeMatch = true
            case 4...10:
                score += 5
                evidence.runtimeMatch = true
            case 11...20:
                score += 2
            case 61...:
                score -= 3
            default:
                break
            }
        }

        if let sourceType = source.mediaType {
            if sourceType == candidate.identity.type {
                score += 8
                evidence.mediaTypeMatch = true
            } else {
                score -= 3
            }
        }

        return TitleImportScoredCandidate(candidate: candidate, score: score, evidence: evidence)
    }
    // swiftlint:enable function_body_length

    /// Checks a generated source variant without allowing unqualified subtitle removal.
    /// - Parameters:
    ///   - candidateTitle: The candidate title to compare.
    ///   - sourceTitle: The unmodified source title used to classify subtitle removal.
    ///   - sourceVariants: The ordered variants generated from the source title.
    ///   - exactYearMatch: Whether a colon-delimited subtitle may be removed safely.
    /// - Returns: Whether the candidate matches an allowed non-primary source variant.
    private func matchesSourceVariant(
        _ candidateTitle: String,
        sourceTitle: String,
        sourceVariants: [String],
        exactYearMatch: Bool
    ) -> Bool {
        let normalizedCandidate = TitleImportTitleMatcher.normalize(candidateTitle)
        guard sourceVariants.dropFirst().contains(where: { sourceVariant in
            TitleImportTitleMatcher.normalize(sourceVariant) == normalizedCandidate
        }) else { return false }
        let wouldRemoveSubtitle = TitleImportTitleMatcher.equivalence(
            between: sourceTitle,
            and: candidateTitle,
            exactYearMatch: true
        ) == .subtitle
        return !wouldRemoveSubtitle || exactYearMatch
    }
}
