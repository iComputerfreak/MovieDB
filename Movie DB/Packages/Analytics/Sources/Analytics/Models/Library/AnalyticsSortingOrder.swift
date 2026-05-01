// Copyright © 2026 Jonas Frey. All rights reserved.

public enum AnalyticsSortingOrder: String, Sendable {
    case name
    case created
    case releaseDate = "release_date"
    case rating
    case watchDate = "watch_date"
}
