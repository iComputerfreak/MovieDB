//
//  NewSeasonsMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 16.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct NewSeasonsMediaList: View {
    @Binding var selectedMediaObjects: Set<Media>
    @ObservedObject private var list: PredicateMediaList = .newSeasons

    var body: some View {
        PredicateMediaListView(
            selectedMediaObjects: $selectedMediaObjects,
            list: list
        ) { media in
            LibraryRow(subtitleContent: list.subtitleContent)
                .mediaSwipeActions()
                .mediaContextMenu()
                .environmentObject(media)
                .navigationLinkChevron()
        }
    }
}

#Preview {
    NavigationStack {
        NewSeasonsMediaList(selectedMediaObjects: .constant([PlaceholderData.preview.staticMovie]))
            .previewEnvironment()
    }
}
