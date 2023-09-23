//
//  WatchlistMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.09.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct WatchlistMediaList: View {
    @Binding var selectedMedia: Media?
    
    var body: some View {
        FilteredMediaList(
            list: PredicateMediaList.watchlist,
            selectedMedia: $selectedMedia
        ) { media in
            NavigationLink(value: media) {
                LibraryRow()
                    .swipeActions {
                        Button(Strings.Lists.removeMediaLabel) {
                            media.isOnWatchlist = false
                        }
                    }
                    .mediaContextMenu()
                    .environmentObject(media)
            }
        }
    }
}

#Preview {
    WatchlistMediaList(selectedMedia: .constant(nil))
}
