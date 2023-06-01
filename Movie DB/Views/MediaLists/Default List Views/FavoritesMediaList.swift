//
//  FavoritesMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.09.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FavoritesMediaList: View {
    @Binding var selectedMedia: Media?
    
    var body: some View {
        FilteredMediaList(
            list: PredicateMediaList.favorites,
            selectedMedia: $selectedMedia
        ) { media in
            NavigationLink(value: media) {
                LibraryRow()
                    .environmentObject(media)
                    .swipeActions {
                        Button(Strings.Detail.menuButtonUnfavorite) {
                            assert(media.isFavorite)
                            media.isFavorite = false
                        }
                    }
            }
        }
    }
}

struct FavoritesMediaList_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesMediaList(selectedMedia: .constant(nil))
    }
}
