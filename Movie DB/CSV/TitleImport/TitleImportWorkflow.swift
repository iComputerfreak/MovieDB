// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation
import Observation

@MainActor
@Observable
/// Owns title-import UI state and coordinates parsing, resolution, review, and final import stages.
final class TitleImportWorkflow: Identifiable {
    /// Identifies the screen or operation currently presented by the workflow.
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
    var resolutionTotalCount = 0
    var finalImportProcessedCount = 0
    var finalImportTotalCount = 0
    var finalResult: TitleImportFinalResult?
    var reportData: Data?
    var error: Error?
    var reviewFilter: TitleImportReviewFilter = .all
    var reviewSearchText = ""

    /// Creates a workflow for one security-scoped CSV file.
    /// - Parameters:
    ///   - fileURL: The selected CSV file URL.
    ///   - resolver: The resolver used to match parsed rows to TMDB candidates.
    ///   - finalImporter: The importer used to persist confirmed identities.
    init(
        fileURL: URL,
        resolver: TitleImportResolver = TitleImportResolver(),
        finalImporter: TitleImportFinalImporter = TitleImportFinalImporter()
    ) {
        self.fileURL = fileURL
        self.resolver = resolver
        self.finalImporter = finalImporter
    }

    var totalCount: Int {
        stage == .resolving ? resolutionTotalCount : preflight?.usableRowCount ?? 0
    }
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
            case .notIncluded: !item.isIncluded
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

    /// Parses the selected file and transitions to preflight or failure.
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

    /// Starts candidate resolution, deduplication, and free-limit selection enforcement.
    func startResolution() {
        guard let preflight, preflight.canStartResolution, resolutionTask == nil else { return }
        stage = .resolving
        processedCount = 0
        resolutionTotalCount = preflight.usableRowCount
        let shouldDisableIdleTimer: Bool
        if #available(iOS 26.0, *) {
            shouldDisableIdleTimer = false
        } else {
            shouldDisableIdleTimer = true
        }
        // Keep older-system foreground-only resolution progressing through long imports.
        let idleTimerController = IdleTimerController(disabling: shouldDisableIdleTimer)
        resolutionTask = Task { [weak self, resolver] in
            defer {
                idleTimerController.restore()
            }
            guard let self else { return }
            defer {
                resolutionTask = nil
            }
            do {
                // Apply the confirmed mappings away from the main actor before starting network resolution.
                let parser = TitleImportCSVParser()
                let rows = await Task.detached(priority: .userInitiated) {
                    parser.sourceRows(from: preflight)
                }.value
                try Task.checkCancellation()
                // Resolve, deduplicate, and enforce entitlement limits before exposing mutable review state.
                let items = try await resolver.startResolution(rows) { [weak self] count in
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

    /// Requests cancellation of the active resolution task.
    func cancelResolution() {
        resolutionTask?.cancel()
    }

    /// Clears a loading failure and starts parsing the selected file again.
    func retryLoading() {
        error = nil
        stage = .loading
        Task { await loadFile() }
    }

    /// Updates a review item's inclusion state when status and entitlement constraints allow it.
    /// - Parameters:
    ///   - included: Whether the review item should be selected for import.
    ///   - itemID: The source-row identifier of the review item.
    func setIncluded(_ included: Bool, itemID: Int) {
        guard let index = reviewItems.firstIndex(where: { $0.id == itemID }), !reviewItems[index].inclusionLocked else {
            return
        }
        if included, let freeSelectionLimit, includedCount >= freeSelectionLimit {
            return
        }
        reviewItems[index].isIncluded = included
    }

    /// Counts review items with a specific status.
    /// - Parameter status: The review status to count.
    /// - Returns: The number of matching review items.
    func count(for status: TitleImportReviewStatus) -> Int {
        reviewItems.filter { $0.status == status }.count
    }

    /// Deselects included items beyond the current free-library capacity in source order.
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

    /// Reads and parses a security-scoped CSV file outside main-actor isolation.
    /// - Parameter url: The security-scoped file URL to parse.
    /// - Returns: Parsed preflight metadata and source rows.
    /// - Throws: `ImportError.noPermissions`, a file-reading error, a CSV parsing error, or cancellation.
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
    var isPerformingWork: Bool { stage == .resolving || stage == .importing }
    var reportFilename: String { "MovieDB_Title_Import_Report_\(Utils.isoDateString()).csv" }

    /// Freezes currently included identities and advances to final confirmation.
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

    /// Returns from confirmation to editable review state.
    func returnToReview() {
        guard stage == .confirmation else { return }
        stage = .review
    }

    /// Starts final import for the identities frozen at confirmation.
    func startImport() {
        guard stage == .confirmation, !frozenIdentities.isEmpty else { return }
        runFinalImport(frozenIdentities, preserving: nil)
    }

    /// Starts another final-import attempt containing only previously failed identities.
    func retryFailedImports() {
        guard stage == .summary, let finalResult, !finalResult.failedIdentities.isEmpty else { return }
        runFinalImport(finalResult.failedIdentities, preserving: finalResult)
    }

    /// Requests cancellation of the active resolution or final-import task.
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

    /// Runs one final-import attempt and merges retry results with prior successful outcomes.
    /// - Parameters:
    ///   - identities: The identities to import during this attempt.
    ///   - previousResult: A previous summary whose completed counts should be preserved, or `nil`.
    private func runFinalImport(
        _ identities: [MediaIdentity],
        preserving previousResult: TitleImportFinalResult?
    ) {
        guard importTask == nil else { return }
        stage = .importing
        finalImportProcessedCount = 0
        finalImportTotalCount = identities.count
        let idleTimerController = IdleTimerController(disabling: true)
        let libraryLimit = StoreManager.shared.hasPurchasedPro ? nil : JFLiterals.nonProMediaLimit
        importTask = Task { [weak self, finalImporter] in
            defer {
                idleTimerController.restore()
            }
            guard let self else { return }
            defer {
                importTask = nil
            }
            // Keep committed prior results while replacing retryable failures with this attempt's outcome.
            let result = await finalImporter.startMediaImport(
                identities: identities,
                libraryLimit: libraryLimit
            ) { [weak self] count in
                self?.finalImportProcessedCount = count
            }

            if let previousResult {
                finalResult = TitleImportFinalResult(
                    importedCount: previousResult.importedCount + result.importedCount,
                    duplicateCount: previousResult.duplicateCount + result.duplicateCount,
                    importedIdentities: previousResult.importedIdentities + result.importedIdentities,
                    duplicateIdentities: previousResult.duplicateIdentities + result.duplicateIdentities,
                    failedIdentities: result.failedIdentities,
                    remainingIdentities: previousResult.remainingIdentities + result.remainingIdentities
                )
            } else {
                finalResult = result
            }
            if let finalResult, let preflight {
                reportData = TitleImportReportExporter.createData(
                    preflight: preflight,
                    reviewItems: reviewItems,
                    result: finalResult
                )
            }
            stage = .summary
        }
    }
}
