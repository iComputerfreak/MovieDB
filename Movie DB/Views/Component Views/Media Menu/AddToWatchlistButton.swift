//
//  AddToWatchlistButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Analytics
import SwiftUI

struct AddToWatchlistButton: View {
    @EnvironmentObject private var mediaObject: Media

    var body: some View {
        Button {
            let newValue = !mediaObject.isOnWatchlist
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
