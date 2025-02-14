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
    
    var body: some View {
        FilteredMediaList(
            list: PredicateMediaList.watchlist,
            selectedMediaObjects: $selectedMediaObjects
        ) { media in
            LibraryRow(subtitleContent: .watchState)
                .swipeActions {
                    Button {
                        media.isOnWatchlist = false
                    } label: {
                        Label(Strings.Lists.removeMediaLabel, systemImage: "bookmark.slash.fill")
                            .labelStyle(.iconOnly)
                            .tint(.blue)
                    }
                }
                .mediaContextMenu()
                .environmentObject(media)
                .navigationLinkChevron()
        }
    }
}

#Preview {
    WatchlistMediaList(selectedMediaObjects: .constant([]))
}
