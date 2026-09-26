// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class TitleImportWorkflow: Identifiable {
    enum Stage: Equatable {
        case loading
        case preflight
        case resolving
        case review
        case confirmation
        case importing
        case summary
        case failure
    }

    let id = UUID()
    private let fileURL: URL
    private let resolver: TitleImportResolver
    private let finalImporter: TitleImportFinalImporter
    private var resolutionTask: Task<Void, Never>?
    private var importTask: Task<Void, Never>?
    private var frozenIdentities: [MediaIdentity] = []

    var stage: Stage = .loading
    var preflight: TitleImportPreflight?
    var reviewItems: [TitleImportReviewItem] = []
    var processedCount = 0
    var finalImportProcessedCount = 0
    var finalImportTotalCount = 0
    var finalResult: TitleImportFinalResult?
    var error: Error?
    var reviewFilter: TitleImportReviewFilter = .all
    var reviewSearchText = ""

    init(
        fileURL: URL,
        resolver: TitleImportResolver = TitleImportResolver(),
        finalImporter: TitleImportFinalImporter = TitleImportFinalImporter()
    ) {
        self.fileURL = fileURL
        self.resolver = resolver
        self.finalImporter = finalImporter
    }

    var totalCount: Int { preflight?.rows.count ?? 0 }
    var includedCount: Int { reviewItems.filter(\.isIncluded).count }
    var freeSelectionLimit: Int? {
        guard !StoreManager.shared.hasPurchasedPro else { return nil }
        return max(0, JFLiterals.nonProMediaLimit - (MediaLibrary.shared.mediaCount() ?? 0))
    }
    var filteredReviewItems: [TitleImportReviewItem] {
        reviewItems.filter { item in
            let matchesFilter = switch reviewFilter {
            case .all: true
            case .included: item.isIncluded
            case .ambiguous: item.status == .ambiguous
            case .duplicate: item.status == .duplicate
            case .noMatch: item.status == .noMatch
            case .failed: item.status == .failed
            }
            guard matchesFilter else { return false }
            let query = reviewSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
            return query.isEmpty || item.source.title.localizedStandardContains(query) ||
                (item.candidate?.title.localizedStandardContains(query) ?? false)
        }
    }

    func loadFile() async {
        guard stage == .loading else { return }
        do {
            preflight = try await Self.parseFile(at: fileURL)
            stage = .preflight
        } catch {
            self.error = error
            stage = .failure
        }
    }

    func startResolution() {
        guard let preflight, resolutionTask == nil else { return }
        stage = .resolving
        processedCount = 0
        let priorIdleTimerState = UIApplication.shared.isIdleTimerDisabled
        // Resolution is foreground-only; prevent auto-lock while a long import is actively progressing.
        UIApplication.shared.isIdleTimerDisabled = true
        resolutionTask = Task { [weak self, resolver] in
            defer {
                UIApplication.shared.isIdleTimerDisabled = priorIdleTimerState
            }
            guard let self else { return }
            defer {
                resolutionTask = nil
            }
            do {
                let items = try await resolver.resolve(preflight.rows) { [weak self] count in
                    self?.processedCount = count
                }
                let existing = try await TitleImportDeduplicator.existingIdentities()
                reviewItems = TitleImportDeduplicator.apply(to: items, existingIdentities: existing)
                applyFreeSelectionLimit()
                stage = .review
            } catch is CancellationError {
                stage = .preflight
            } catch {
                self.error = error
                stage = .failure
            }
        }
    }

    func cancelResolution() {
        resolutionTask?.cancel()
    }

    func retryLoading() {
        error = nil
        stage = .loading
        Task { await loadFile() }
    }

    func setIncluded(_ included: Bool, itemID: Int) {
        guard let index = reviewItems.firstIndex(where: { $0.id == itemID }), !reviewItems[index].inclusionLocked else {
            return
        }
        if included, let freeSelectionLimit, includedCount >= freeSelectionLimit {
            return
        }
        reviewItems[index].isIncluded = included
    }

    func count(for status: TitleImportReviewStatus) -> Int {
        reviewItems.filter { $0.status == status }.count
    }

    private func applyFreeSelectionLimit() {
        guard let freeSelectionLimit else { return }
        var remaining = freeSelectionLimit
        for index in reviewItems.indices where reviewItems[index].isIncluded {
            if remaining > 0 {
                remaining -= 1
            } else {
                reviewItems[index].isIncluded = false
            }
        }
    }

    private nonisolated static func parseFile(at url: URL) async throws -> TitleImportPreflight {
        // File decoding and large CSV parsing do not need main-actor isolation.
        try await Task.detached(priority: .userInitiated) {
            guard url.startAccessingSecurityScopedResource() else { throw ImportError.noPermissions }
            defer { url.stopAccessingSecurityScopedResource() }
            let string = try String(contentsOf: url, encoding: .utf8)
            return try TitleImportCSVParser().parse(string: string)
        }.value
    }
}

// MARK: - Final Import
extension TitleImportWorkflow {
    var excludedCount: Int { reviewItems.count - includedCount }
    var ambiguousIncludedCount: Int {
        reviewItems.filter { $0.status == .ambiguous && $0.isIncluded }.count
    }
    var existingDuplicateCount: Int {
        reviewItems.filter { $0.duplicateKind == .existingLibrary }.count
    }
    var fileDuplicateCount: Int { count(for: .duplicate) - existingDuplicateCount }
    var estimatedImportSeconds: Int {
        guard includedCount > 0 else { return 0 }
        return Int(ceil(Double(includedCount) / Double(TMDBAPI.maxRequestsPerSecond)))
    }
    var isPerformingWork: Bool { stage == .resolving || stage == .importing }

    func prepareForImport() {
        applyFreeSelectionLimit()
        // Freeze identities at confirmation so later review-state changes cannot alter an active import.
        frozenIdentities = reviewItems.compactMap { item in
            guard item.isIncluded else { return nil }
            return item.candidate?.identity
        }
        guard !frozenIdentities.isEmpty else { return }
        stage = .confirmation
    }

    func returnToReview() {
        guard stage == .confirmation else { return }
        stage = .review
    }

    func startImport() {
        guard stage == .confirmation, !frozenIdentities.isEmpty else { return }
        runFinalImport(frozenIdentities, preserving: nil)
    }

    func retryFailedImports() {
        guard stage == .summary, let finalResult, !finalResult.failedIdentities.isEmpty else { return }
        runFinalImport(finalResult.failedIdentities, preserving: finalResult)
    }

    func cancelCurrentWork() {
        switch stage {
        case .resolving:
            resolutionTask?.cancel()
        case .importing:
            importTask?.cancel()
        default:
            break
        }
    }

    private func runFinalImport(
        _ identities: [MediaIdentity],
        preserving previousResult: TitleImportFinalResult?
    ) {
        guard importTask == nil else { return }
        stage = .importing
        finalImportProcessedCount = 0
        finalImportTotalCount = identities.count
        let priorIdleTimerState = UIApplication.shared.isIdleTimerDisabled
        UIApplication.shared.isIdleTimerDisabled = true
        let libraryLimit = StoreManager.shared.hasPurchasedPro ? nil : JFLiterals.nonProMediaLimit
        importTask = Task { [weak self, finalImporter] in
            defer {
                UIApplication.shared.isIdleTimerDisabled = priorIdleTimerState
            }
            guard let self else { return }
            defer {
                importTask = nil
            }
            let result = await finalImporter.importMedia(identities: identities, libraryLimit: libraryLimit) { [weak self] count in
                self?.finalImportProcessedCount = count
            }
            if let previousResult {
                finalResult = TitleImportFinalResult(
                    importedCount: previousResult.importedCount + result.importedCount,
                    duplicateCount: previousResult.duplicateCount + result.duplicateCount,
                    failedIdentities: result.failedIdentities,
                    remainingIdentities: previousResult.remainingIdentities + result.remainingIdentities
                )
            } else {
                finalResult = result
            }
            stage = .summary
        }
    }
}
