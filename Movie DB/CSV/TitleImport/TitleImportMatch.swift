// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

enum TitleImportReviewStatus: String, CaseIterable, Sendable {
    case accepted
    case ambiguous
    case duplicate
    case noMatch
    case failed
}

enum TitleImportDuplicateKind: Equatable, Sendable {
    case existingLibrary
    case sourceRow(Int)
}

struct TitleImportMatchEvidence: Hashable, Sendable {
    var titleMatch = false
    var alternativeTitleMatch = false
    var yearMatch = false
    var directorMatch = false
    var runtimeMatch = false
    var mediaTypeMatch = false
}

struct TitleImportScoredCandidate: Sendable {
    let candidate: TitleImportCandidate
    let score: Double
    let evidence: TitleImportMatchEvidence
}

struct TitleImportReviewItem: Identifiable, Sendable {
    let id: Int
    let source: TitleImportSourceRow
    let candidate: TitleImportCandidate?
    var status: TitleImportReviewStatus
    var duplicateKind: TitleImportDuplicateKind? = nil
    var reason: String
    let evidence: TitleImportMatchEvidence
    var isIncluded: Bool

    var inclusionLocked: Bool {
        status == .duplicate || status == .noMatch || status == .failed
    }
}
