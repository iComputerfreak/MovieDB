//
//  MediaMenu+AddToWatchlist.swift
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
        } label: {
            if mediaObject.isOnWatchlist {
                Label(Strings.Detail.menuButtonRemoveFromWatchlist, systemImage: "bookmark.fill")
            } else {
                Label(Strings.Detail.menuButtonAddToWatchlist, systemImage: "bookmark")
            }
        }
    }
}

struct MediaMenu_AddToWatchlist_Previews: PreviewProvider {
    static var previews: some View {
        AddToWatchlistButton()
            .environmentObject(PlaceholderData.preview.staticMovie)
    }
}
