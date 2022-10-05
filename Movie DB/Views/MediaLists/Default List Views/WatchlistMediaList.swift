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
        FilteredMediaList(list: PredicateMediaList.watchlist, selectedMedia: $selectedMedia) { media in
            // TODO: Extract NavigationLink? Rework?
            WatchlistRow()
                .environmentObject(media)
                .swipeActions {
                    Button(Strings.Lists.removeMediaLabel) {
                        media.isOnWatchlist = false
                    }
                }
        }
    }
}

struct WatchlistMediaList_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistMediaList(selectedMedia: .constant(nil))
    }
}
