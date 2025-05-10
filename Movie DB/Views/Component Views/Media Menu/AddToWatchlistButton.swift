//
//  AddToWatchlistButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct AddToWatchlistButton: View {
    @EnvironmentObject private var mediaObject: Media
    
    var body: some View {
        Button {
            mediaObject.isOnWatchlist.toggle()
            PersistenceController.saveContext()
        } label: {
            // TODO: I would like this to work, but swipe actions seem to always prefer the .fill variant
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
