// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Describes how confidently a source row was resolved for review.
enum TitleImportReviewStatus: String, CaseIterable, Sendable {
    case accepted
    case ambiguous
    case duplicate
    case noMatch
    case failed
}

/// Identifies whether a duplicate already exists in the library or appeared earlier in the source file.
enum TitleImportDuplicateKind: Equatable, Sendable {
    case existingLibrary
    case sourceRow(Int)
}

/// Records which metadata signals supported a candidate's score.
struct TitleImportMatchEvidence: Hashable, Sendable {
    var titleMatch = false
    var alternativeTitleMatch = false
    var yearMatch = false
    var directorMatch = false
    var runtimeMatch = false
    var mediaTypeMatch = false
}

/// Couples a TMDB candidate with its aggregate score and supporting evidence.
struct TitleImportScoredCandidate: Sendable {
    let candidate: TitleImportCandidate
    let score: Double
    let evidence: TitleImportMatchEvidence
}

/// Represents one source row and its proposed candidate throughout review and deduplication.
struct TitleImportReviewItem: Identifiable, Sendable {
    let id: Int
    let source: TitleImportSourceRow
    let candidate: TitleImportCandidate?
    let score: Double?
    let runnerUpScore: Double?
    var status: TitleImportReviewStatus
    var duplicateKind: TitleImportDuplicateKind? = nil
    var reason: String
    let evidence: TitleImportMatchEvidence
    var isIncluded: Bool

    var inclusionLocked: Bool {
        status == .duplicate || status == .noMatch || status == .failed
    }

    var scoreMargin: Double? {
        guard let score, let runnerUpScore else { return nil }
        return score - runnerUpScore
    }
}
