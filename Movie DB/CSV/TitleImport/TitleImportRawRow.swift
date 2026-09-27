// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Preserves one nonempty CSV row and its original source line for deferred field mapping.
struct TitleImportRawRow: Sendable {
    let rowNumber: Int
    let values: [String]
}
