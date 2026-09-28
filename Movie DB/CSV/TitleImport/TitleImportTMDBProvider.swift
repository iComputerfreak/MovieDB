// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Provides the lightweight TMDB search and enrichment operations needed during title resolution.
protocol TitleImportTMDBProviding: Sendable {
    /// Searches one TMDB result page for a title query.
    /// - Parameters:
    ///   - query: The title query to search.
    ///   - page: The one-based results page to request.
    /// - Returns: Movie and show candidates from the requested page.
    /// - Throws: A network, API, decoding, or cancellation error when the search cannot complete.
    func titleImportSearch(_ query: String, page: Int) async throws -> [TitleImportCandidate]

    /// Loads alternative titles, directors, and runtime for one candidate.
    /// - Parameter identity: The candidate identity to enrich.
    /// - Returns: Matching details shared across movie and show responses.
    /// - Throws: A network, API, decoding, or cancellation error when details cannot be loaded.
    func titleImportDetails(for identity: MediaIdentity) async throws -> TitleImportCandidateDetails
}

extension TMDBAPI: TitleImportTMDBProviding {}
