//
//  NewSeasonsMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 16.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct NewSeasonsMediaList: View {
    @Binding var selectedMedia: Media?
    
    var body: some View {
        FilteredMediaList(
            list: PredicateMediaList.newSeasons,
            selectedMedia: $selectedMedia,
            rowContent: { media in
                NavigationLink(value: media) {
                    LibraryRow()
                        .mediaSwipeActions()
                        .mediaContextMenu()
                        .environmentObject(media)
                }
            }
        )
    }
}

struct NewSeasonsMediaList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewSeasonsMediaList(selectedMedia: .constant(PlaceholderData.preview.staticMovie))
                .environment(\.managedObjectContext, PersistenceController.previewContext)
        }
    }
}
