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
        case failure
    }

    let id = UUID()
    private let fileURL: URL
    private let resolver: TitleImportResolver
    private var resolutionTask: Task<Void, Never>?

    var stage: Stage = .loading
    var preflight: TitleImportPreflight?
    var reviewItems: [TitleImportReviewItem] = []
    var processedCount = 0
    var error: Error?
    var reviewFilter: TitleImportReviewFilter = .all
    var reviewSearchText = ""

    init(fileURL: URL, resolver: TitleImportResolver = TitleImportResolver()) {
        self.fileURL = fileURL
        self.resolver = resolver
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
