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
    @ObservedObject private var list: PredicateMediaList = .problems

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
    ProblemsMediaList(selectedMediaObjects: .constant([]))
        .previewEnvironment()
}
