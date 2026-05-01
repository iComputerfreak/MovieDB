// Copyright © 2023 Jonas Frey. All rights reserved.

import Foundation
import Analytics
import SwiftUI

struct MediaContextMenuModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contextMenu {
                Group {
                    Section {
                        AddToFavoritesButton {
                            AnalyticsService.shared.track(.mediaContextMenuActionUsed(action: .toggleFavorite))
                        }
                        AddToWatchlistButton {
                            AnalyticsService.shared.track(.mediaContextMenuActionUsed(action: .toggleWatchlist))
                        }
                        AddEnvironmentMediaToListMenu {
                            AnalyticsService.shared.track(.mediaContextMenuActionUsed(action: .addToList))
                        }
                    }
                    Section {
                        ReloadMediaButton {
                            AnalyticsService.shared.track(.mediaContextMenuActionUsed(action: .reload))
                        }
                        ShareMediaButton {
                            AnalyticsService.shared.track(.mediaContextMenuActionUsed(action: .share))
                            AnalyticsService.shared.track(.mediaShared(shareTargetType: .systemShareSheet))
                        }
                        DeleteMediaButton(onAction: {
                            AnalyticsService.shared.track(.mediaContextMenuActionUsed(action: .delete))
                        })
                    }
                }
            }
    }
}

extension View {
    func mediaContextMenu() -> some View {
        self.modifier(MediaContextMenuModifier())
    }
}
