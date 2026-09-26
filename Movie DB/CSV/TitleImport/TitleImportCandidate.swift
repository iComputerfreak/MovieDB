// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

struct TitleImportCandidate: Identifiable, Hashable, Sendable {
    let identity: MediaIdentity
    let title: String
    let originalTitle: String
    let year: Int?
    let imagePath: String?
    let popularity: Float
    var alternativeTitles: [String]
    var directors: [String]
    var runtimeMinutes: Int?

    var id: MediaIdentity { identity }
}
