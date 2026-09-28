// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Summarizes completed, duplicate, failed, and unprocessed items from a final import attempt.
struct TitleImportFinalResult: Sendable {
    var importedCount = 0
    var duplicateCount = 0
    var failedIdentities: [MediaIdentity] = []
    var remainingIdentities: [MediaIdentity] = []

    var failedCount: Int { failedIdentities.count }
    var remainingCount: Int { remainingIdentities.count }
}
