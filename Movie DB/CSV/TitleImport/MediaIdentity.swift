// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Identifies a TMDB work by media type and TMDB identifier.
struct MediaIdentity: Codable, Hashable, Sendable {
    let type: MediaType
    let tmdbID: Int
}
