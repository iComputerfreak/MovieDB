// Copyright © 2023 Jonas Frey. All rights reserved.

import Foundation
import Analytics
import SwiftUI

extension View {
    func mediaSwipeActions() -> some View {
        self.modifier(MediaSwipeActionsModifier())
    }
}

struct MediaSwipeActionsModifier: ViewModifier {
    @EnvironmentObject private var mediaObject: Media
    
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                DeleteMediaSwipeAction()

                let watchlistButton = AddToWatchlistButton {
                    AnalyticsService.shared.track(.mediaSwipeActionUsed(action: .toggleWatchlist))
                }
                .labelStyle(.iconOnly)

                if let iconColor = PredicateMediaList.watchlist.iconColor {
                    watchlistButton
                        .tint(Color(iconColor))
                } else {
                    watchlistButton
                }
            }
    }
}
