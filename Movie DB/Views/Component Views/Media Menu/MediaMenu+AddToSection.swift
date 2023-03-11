//
//  MediaMenu+AddToSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import os.log
import SwiftUI

extension MediaMenu {
    struct AddToSection: View {
        @ObservedObject var mediaObject: Media
        @EnvironmentObject var notificationProxy: NotificationProxy
        @FetchRequest(
            entity: UserMediaList.entity(),
            sortDescriptors: [NSSortDescriptor(key: Schema.UserMediaList.name.rawValue, ascending: true)]
        ) var userLists: FetchedResults<UserMediaList>
        
        var body: some View {
            Section {
                // MARK: Favorites
                Button {
                    mediaObject.isFavorite.toggle()
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
                            notificationProxy.show(
                                title: Strings.Detail.addedToListNotificationTitle,
                                subtitle: Strings.Detail.addedToListNotificationMessage(list.name),
                                systemImage: "checkmark"
                            )
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
            MediaMenu.AddToSection(mediaObject: PlaceholderData.movie)
        }
    }
}
