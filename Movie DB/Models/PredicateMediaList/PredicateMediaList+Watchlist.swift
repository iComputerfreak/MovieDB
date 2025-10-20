// Copyright © 2025 Jonas Frey. All rights reserved.

import Foundation
import JFUtils

extension PredicateMediaList {
    static let watchlist = PredicateMediaList(
        name: Strings.Lists.defaultListNameWatchlist,
        subtitleContentUserDefaultsKey: "watchlistSubtitleContent",
        defaultSubtitleContent: .watchState,
        description: Strings.Lists.watchlistDescription,
        iconName: "bookmark.fill",
        iconColor: .blue,
        iconRenderingMode: .monochrome,
        predicate: NSPredicate(
            format: "%K = %@",
            Schema.Media.isOnWatchlist,
            true as NSNumber
        )
    )
}
