// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

protocol TitleImportTMDBProviding: Sendable {
    func titleImportSearch(_ query: String, page: Int) async throws -> [TitleImportCandidate]
    func titleImportDetails(for identity: MediaIdentity) async throws -> TitleImportCandidateDetails
}

extension TMDBAPI: TitleImportTMDBProviding {}
