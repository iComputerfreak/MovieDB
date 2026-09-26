// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

struct TitleImportPreflight: Sendable {
    let rows: [TitleImportSourceRow]
    let delimiter: Character
    let mappedHeaders: [TitleImportField: String]
    let ignoredHeaders: [String]
    let malformedRowCount: Int
}
