//
//  MediaMenu+AddToSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

extension MediaMenu {
    struct AddToSection: View {
        @ObservedObject var mediaObject: Media
        @State private var showingAddToSheet = false
        
        var body: some View {
            Section {
                // MARK: Favorites
                Button {
                    print("Before: \(mediaObject.isFavorite)")
                    mediaObject.isFavorite.toggle()
                    print("After: \(mediaObject.isFavorite)")
                } label: {
                    if mediaObject.isFavorite {
                        Label(Strings.Detail.menuButtonUnfavorite, systemImage: "heart.fill")
                    } else {
                        Label(Strings.Detail.menuButtonFavorite, systemImage: "heart")
                    }
                }
                // MARK: Watchlist
                Button {
                    mediaObject.isOnWatchlist.toggle()
                } label: {
                    if mediaObject.isOnWatchlist {
                        Label(Strings.Detail.menuButtonRemoveFromWatchlist, systemImage: "bookmark.fill")
                    } else {
                        Label(Strings.Detail.menuButtonAddToWatchlist, systemImage: "bookmark")
                    }
                }
                // MARK: Add to...
                // Present popup that asks to which list the media should be added
                Button {
                    self.showingAddToSheet = true
                } label: {
                    Label(Strings.Library.mediaActionAddToList, systemImage: "text.badge.plus")
                }
            }
            .sheet(isPresented: $showingAddToSheet, content: {
                SelectUserListView(mediaObject: mediaObject)
            })
        }
    }
}

struct AddToSection_Previews: PreviewProvider {
    static var previews: some View {
        MediaMenu.AddToSection(mediaObject: PlaceholderData.movie)
    }
}
