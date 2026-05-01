//
//  WatchlistMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.09.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct WatchlistMediaList: View {
    @Binding var selectedMediaObjects: Set<Media>
    @ObservedObject private var list: PredicateMediaList = .watchlist

    var body: some View {
        PredicateMediaListView(
            selectedMediaObjects: $selectedMediaObjects,
            list: list
        ) { media in
            LibraryRow(subtitleContent: list.subtitleContent)
                .swipeActions {
                    Button {
                        media.isOnWatchlist = false
                        PersistenceController.saveContext()
                    } label: {
                        let label = Label(Strings.Lists.removeMediaLabel, systemImage: "bookmark.slash.fill")
                            .labelStyle(.iconOnly)

                        if let iconColor = PredicateMediaList.watchlist.iconColor {
                            label.tint(Color(iconColor))
                        } else {
                            label
                        }
                    }
                }
                .mediaContextMenu()
                .environmentObject(media)
                .navigationLinkChevron()
        } extraMoreMenuItems: {
            Button {
                // Formulating a predicate for seasons that have been fully watched is hard, so we fetch all and filter then
                let fetchRequest = list.buildFetchRequest()
                let allMedia = (try? PersistenceController.viewContext.fetch(fetchRequest)) ?? []
                let watchedMedia = allMedia.filter { media in
                    if let show = media as? Show {
                        return show.isFullyWatched ?? false
                    } else if let movie = media as? Movie {
                        return movie.watched == .watched
                    } else {
                        return false
                    }
                }
                guard !watchedMedia.isEmpty else { return }
                for media in watchedMedia {
                    media.isOnWatchlist = false
                }
                PersistenceController.saveContext()
            } label: {
                Label(
                    Strings.Lists.watchlistRemoveWatchedLabel,
                    systemImage: "eye.fill"
                )
            }
        }
    }
}

#Preview {
    WatchlistMediaList(selectedMediaObjects: .constant([]))
}
