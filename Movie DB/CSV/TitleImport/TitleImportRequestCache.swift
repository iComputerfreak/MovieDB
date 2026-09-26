// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

actor TitleImportRequestCache {
    private struct SearchKey: Hashable {
        let query: String
        let page: Int
    }

    private let provider: any TitleImportTMDBProviding
    // Cache in-flight tasks, not only values, so concurrent duplicate rows share the same request.
    private var searchTasks: [SearchKey: Task<[TitleImportCandidate], Error>] = [:]
    private var detailTasks: [MediaIdentity: Task<TitleImportCandidateDetails, Error>] = [:]

    init(provider: any TitleImportTMDBProviding) {
        self.provider = provider
    }

    func search(_ query: String, page: Int = 1) async throws -> [TitleImportCandidate] {
        let key = SearchKey(query: query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), page: page)
        if let task = searchTasks[key] { return try await value(of: task) }
        let task = Task { [provider] in
            try await Self.retry { try await provider.titleImportSearch(query, page: page) }
        }
        searchTasks[key] = task
        return try await value(of: task)
    }

    func details(for identity: MediaIdentity) async throws -> TitleImportCandidateDetails {
        if let task = detailTasks[identity] { return try await value(of: task) }
        let task = Task { [provider] in
            try await Self.retry { try await provider.titleImportDetails(for: identity) }
        }
        detailTasks[identity] = task
        return try await value(of: task)
    }

    private func value<T: Sendable>(of task: Task<T, Error>) async throws -> T {
        // Cached tasks are unstructured; explicitly propagate import cancellation into the network operation.
        try await withTaskCancellationHandler {
            try await task.value
        } onCancel: {
            task.cancel()
        }
    }

    private static func retry<T: Sendable>(
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        for attempt in 0..<4 {
            do {
                try Task.checkCancellation()
                return try await operation()
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                lastError = error
                guard attempt < 3 else { break }
                // Back off for 1, 2, then 4 seconds before surfacing the final failure.
                try await Task.sleep(for: .seconds(Int(pow(2, Double(attempt)))))
            }
        }
        throw lastError ?? CancellationError()
    }
}
