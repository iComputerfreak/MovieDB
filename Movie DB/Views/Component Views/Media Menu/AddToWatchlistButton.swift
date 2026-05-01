// Copyright © 2023 Jonas Frey. All rights reserved.

import Analytics
import SwiftUI

struct AddToWatchlistButton: View {
    @EnvironmentObject private var mediaObject: Media
    var onAction: (() -> Void)? = nil

    var body: some View {
        Button {
            let newValue = !mediaObject.isOnWatchlist
            onAction?()
            mediaObject.isOnWatchlist.toggle()
            AnalyticsService.shared.track(.watchlistToggled(newValue: newValue))
            PersistenceController.saveContext()
        } label: {
            if mediaObject.isOnWatchlist {
                Label(Strings.Detail.menuButtonRemoveFromWatchlist, systemImage: "bookmark.slash.fill")
            } else {
                Label(Strings.Detail.menuButtonAddToWatchlist, systemImage: "bookmark.fill")
            }
        }
    }
}

#Preview {
    AddToWatchlistButton()
        .previewEnvironment()
}
