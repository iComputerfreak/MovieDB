// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Contains normalized matching hints parsed from one source CSV row.
struct TitleImportSourceRow: Identifiable, Sendable {
    let id: Int
    let title: String
    let year: Int?
    let directors: [String]
    let runtimeMinutes: Int?
    let mediaType: MediaType?

    var rowNumber: Int { id }
}
