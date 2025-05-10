//
//  UpcomingMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 31.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct UpcomingMediaList: View {
    @Binding var selectedMediaObjects: Set<Media>
    
    var body: some View {
        PredicateMediaListView(
            selectedMediaObjects: $selectedMediaObjects,
            list: PredicateMediaList.upcoming
        ) { media in
            UpcomingLibraryRow()
                .mediaSwipeActions()
                .mediaContextMenu()
                .environmentObject(media)
                .navigationLinkChevron()
        }
    }
}

#Preview {
    NavigationStack {
        UpcomingMediaList(selectedMediaObjects: .constant([PlaceholderData.preview.staticMovie]))
            .previewEnvironment()
    }
}
