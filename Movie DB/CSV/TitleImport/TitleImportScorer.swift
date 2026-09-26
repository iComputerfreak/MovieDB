// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

struct TitleImportScorer {
    // swiftlint:disable:next function_body_length
    func score(_ candidate: TitleImportCandidate, for source: TitleImportSourceRow) -> TitleImportScoredCandidate {
        let sourceVariants = TitleImportTitleMatcher.variants(for: source.title)
        let candidateTitles = [candidate.title, candidate.originalTitle] + candidate.alternativeTitles
        let normalizedSource = sourceVariants.map(TitleImportTitleMatcher.normalize)
        let normalizedCandidates = candidateTitles.map(TitleImportTitleMatcher.normalize)

        let rawTitle = normalizedSource.first ?? ""
        let rawExact = normalizedCandidates.contains(rawTitle)
        let variantExact = normalizedSource.dropFirst().contains { normalizedCandidates.contains($0) }
        let alternativeExact = candidate.alternativeTitles
            .map(TitleImportTitleMatcher.normalize)
            .contains(where: normalizedSource.contains)
        let similarity = sourceVariants.flatMap { sourceTitle in
            candidateTitles.map { TitleImportTitleMatcher.similarity(sourceTitle, $0) }
        }
            .max() ?? 0

        var evidence = TitleImportMatchEvidence()
        evidence.titleMatch = rawExact || variantExact
        evidence.alternativeTitleMatch = alternativeExact

        var score: Double
        if rawExact {
            score = 75
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
}
