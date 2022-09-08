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
        @Binding var viewConfig: MediaMenuViewConfig
        @FetchRequest(
            entity: UserMediaList.entity(),
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
        ) var userLists: FetchedResults<UserMediaList>
        
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
                // sub-menu that asks to which list the media should be added
                // only shows when it has at least one entry (at least one user list exists)
                Menu {
                    ForEach(userLists) { (list: UserMediaList) in
                        Button {
                            mediaObject.userLists.insert(list)
                            viewConfig.showAddedToListNotification(listName: list.name)
                        } label: {
                            Label(list.name, systemImage: list.iconName)
                        }
                        // Disable the "Add to..." button if the media is already in the list
                        // !!!: Does not seem to work in simulator, but works on real device
                        .disabled(mediaObject.userLists.contains(list))
                    }
                } label: {
                    Label(Strings.Library.mediaActionAddToList, systemImage: "text.badge.plus")
                }
            }
        }
    }
}

struct AddToSection_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 8) {
            MediaMenu.AddToSection(mediaObject: PlaceholderData.movie, viewConfig: .constant(.init()))
        }
    }
}
