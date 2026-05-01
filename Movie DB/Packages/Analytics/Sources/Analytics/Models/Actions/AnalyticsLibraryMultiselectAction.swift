// Copyright © 2026 Jonas Frey. All rights reserved.

public enum AnalyticsLibraryMultiselectAction: String, Sendable {
    case selectAll = "select_all"
    case deselectAll = "deselect_all"
    case addToList = "add_to_list"
    case toggleWatchlist = "toggle_watchlist"
    case toggleFavorite = "toggle_favorite"
    case markWatched = "mark_watched"
    case markNotWatched = "mark_not_watched"
    case reload
    case delete
}
