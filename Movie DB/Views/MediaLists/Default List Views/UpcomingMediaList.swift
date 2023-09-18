//
//  UpcomingMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 31.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct UpcomingMediaList: View {
    @Binding var selectedMedia: Media?
    
    var body: some View {
        FilteredMediaList(
            list: PredicateMediaList.upcoming,
            selectedMedia: $selectedMedia,
            rowContent: { media in
                NavigationLink(value: media) {
                    UpcomingLibraryRow()
                        .mediaSwipeActions()
                        .mediaContextMenu()
                        .environmentObject(media)
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        UpcomingMediaList(selectedMedia: .constant(PlaceholderData.preview.staticMovie))
            .previewEnvironment()
    }
}
