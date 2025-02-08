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
    
    var body: some View {
        FilteredMediaList(
            list: PredicateMediaList.newSeasons,
            selectedMediaObjects: $selectedMediaObjects,
            rowContent: { media in
                LibraryRow(subtitleContent: .watchState)
                    .mediaSwipeActions()
                    .mediaContextMenu()
                    .environmentObject(media)
                    .navigationLinkChevron()
            }
        )
    }
}

#Preview {
    NavigationStack {
        NewSeasonsMediaList(selectedMediaObjects: .constant([PlaceholderData.preview.staticMovie]))
            .previewEnvironment()
    }
}
