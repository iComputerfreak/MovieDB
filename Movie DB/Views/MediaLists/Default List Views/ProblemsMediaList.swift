//
//  ProblemsMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.09.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ProblemsMediaList: View {
    @Binding var selectedMedia: Media?
    
    var body: some View {
        FilteredMediaList(
            list: PredicateMediaList.problems,
            selectedMedia: $selectedMedia
        ) { media in
            NavigationLink(value: media) {
                ProblemsLibraryRow()
                    .mediaSwipeActions()
                    .mediaContextMenu()
                    .environmentObject(media)
            }
        }
    }
}

#Preview {
    ProblemsMediaList(selectedMedia: .constant(nil))
        .previewEnvironment()
}
