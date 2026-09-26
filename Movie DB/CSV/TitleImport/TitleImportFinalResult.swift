// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

struct TitleImportFinalResult: Sendable {
    var importedCount = 0
    var duplicateCount = 0
    var failedIdentities: [MediaIdentity] = []
    var remainingIdentities: [MediaIdentity] = []

    var failedCount: Int { failedIdentities.count }
    var remainingCount: Int { remainingIdentities.count }
}
