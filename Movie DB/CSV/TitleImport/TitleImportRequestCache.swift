// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Coalesces repeated TMDB requests and retries transient failures within one resolver session.
actor TitleImportRequestCache {
    /// Identifies one normalized title-search page in the request cache.
    private struct SearchKey: Hashable {
        let query: String
        let page: Int
    }

    private let provider: any TitleImportTMDBProviding
    // Cache in-flight tasks, not only values, so concurrent duplicate rows share the same request.
    private var searchTasks: [SearchKey: Task<[TitleImportCandidate], Error>] = [:]
    private var detailTasks: [MediaIdentity: Task<TitleImportCandidateDetails, Error>] = [:]

    /// Creates an import-scoped request cache.
    /// - Parameter provider: The provider used to perform uncached TMDB requests.
    init(provider: any TitleImportTMDBProviding) {
        self.provider = provider
    }

    /// Returns a shared, retried search result for a normalized query and page.
    /// - Parameters:
    ///   - query: The title query to search.
    ///   - page: The one-based results page to request.
    /// - Returns: Candidates from the requested search page.
    /// - Throws: The final provider error after retries, or `CancellationError` when the caller is cancelled.
    func search(_ query: String, page: Int = 1) async throws -> [TitleImportCandidate] {
        let key = SearchKey(query: query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), page: page)
        if let task = searchTasks[key] { return try await value(of: task) }
        let task = Task { [provider] in
            try await Self.retry { try await provider.titleImportSearch(query, page: page) }
        }
        searchTasks[key] = task
        return try await value(of: task)
    }

    /// Returns shared, retried enrichment details for a media identity.
    /// - Parameter identity: The candidate identity to enrich.
    /// - Returns: Alternative titles, directors, and runtime for the identity.
    /// - Throws: The final provider error after retries, or `CancellationError` when the caller is cancelled.
    func details(for identity: MediaIdentity) async throws -> TitleImportCandidateDetails {
        if let task = detailTasks[identity] { return try await value(of: task) }
        let task = Task { [provider] in
            try await Self.retry { try await provider.titleImportDetails(for: identity) }
        }
        detailTasks[identity] = task
        return try await value(of: task)
    }

    /// Awaits a cached unstructured task while forwarding caller cancellation.
    /// - Parameter task: The cached request task to await.
    /// - Returns: The request task's value.
    /// - Throws: The task's provider error or `CancellationError` when either task is cancelled.
    private func value<T: Sendable>(of task: Task<T, Error>) async throws -> T {
        // Cached tasks are unstructured; explicitly propagate import cancellation into the network operation.
        try await withTaskCancellationHandler {
            try await task.value
        } onCancel: {
            task.cancel()
        }
    }

    /// Retries an asynchronous operation up to four times with exponential backoff.
    /// - Parameter operation: The operation to execute and retry.
    /// - Returns: The first successful operation value.
    /// - Throws: `CancellationError` immediately on cancellation, or the final operation error after all attempts.
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
