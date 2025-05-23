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
    @ObservedObject private var list: PredicateMediaList = .favorites

    var body: some View {
        PredicateMediaListView(
            selectedMediaObjects: $selectedMediaObjects,
            list: list
        ) { media in
            LibraryRow(subtitleContent: list.subtitleContent)
                .swipeActions {
                    Button {
                        assert(media.isFavorite)
                        media.isFavorite = false
                    } label: {
                        Label(Strings.Detail.menuButtonUnfavorite, systemImage: "heart.slash.fill")
                            .labelStyle(.iconOnly)
                            .tint(.red)
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
