// Copyright © 2026 Jonas Frey. All rights reserved.

public enum AnalyticsFilterType: String, Sendable {
    case unconfigured
    case adult
    case mediaType = "media_type"
    case genre
    case rating
    case year
    case status
    case showType = "show_type"
    case numberOfSeasons = "number_of_seasons"
    case watchState = "watch_state"
    case watchAgain = "watch_again"
    case tag
    case watchProvider = "watch_provider"
    case compound
}
