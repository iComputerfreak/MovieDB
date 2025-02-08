//
//  ProblemsMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.09.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ProblemsMediaList: View {
    @Binding var selectedMediaObjects: Set<Media>
    
    var body: some View {
        FilteredMediaList(
            list: PredicateMediaList.problems,
            selectedMediaObjects: $selectedMediaObjects
        ) { media in
            LibraryRow(subtitleContent: .problems)
                .mediaSwipeActions()
                .mediaContextMenu()
                .environmentObject(media)
                .navigationLinkChevron()
        }
    }
}

#Preview {
    ProblemsMediaList(selectedMediaObjects: .constant([]))
        .previewEnvironment()
}
