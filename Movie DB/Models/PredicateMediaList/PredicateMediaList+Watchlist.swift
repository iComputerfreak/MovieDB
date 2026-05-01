// Copyright © 2025 Jonas Frey. All rights reserved.

import Foundation
import JFUtils
import SwiftUI

extension PredicateMediaList {
    static let watchlist = PredicateMediaList(
        name: Strings.Lists.defaultListNameWatchlist,
        subtitleContentUserDefaultsKey: "watchlistSubtitleContent",
        defaultSubtitleContent: .watchState,
        description: Strings.Lists.watchlistDescription,
        iconName: "bookmark.fill",
        iconColor: UIColor(Color.blue),
        iconRenderingMode: .monochrome,
        predicate: NSPredicate(
            format: "%K = %@",
            Schema.Media.isOnWatchlist,
            true as NSNumber
        )
    )
}
