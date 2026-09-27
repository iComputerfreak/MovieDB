// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

struct TitleImportPreflight: Sendable {
    let rows: [TitleImportSourceRow]
    let delimiter: Character
    let allHeaders: [String]
    var headerMappings: [TitleImportField: String?]
    let ignoredHeaders: [String]
    let malformedRowCount: Int
}
