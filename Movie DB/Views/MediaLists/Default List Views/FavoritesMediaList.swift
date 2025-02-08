//
//  FavoritesMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.09.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FavoritesMediaList: View {
    @Binding var selectedMediaObjects: Set<Media>
    
    var body: some View {
        FilteredMediaList(
            list: PredicateMediaList.favorites,
            selectedMediaObjects: $selectedMediaObjects
        ) { media in
            // TODO: Rating
            LibraryRow(subtitleContent: .watchState)
                .swipeActions {
                    Button(Strings.Detail.menuButtonUnfavorite) {
                        assert(media.isFavorite)
                        media.isFavorite = false
                    }
                }
                .mediaContextMenu()
                .environmentObject(media)
                .navigationLinkChevron()
        }
    }
}

#Preview {
    FavoritesMediaList(selectedMediaObjects: .constant([]))
}
