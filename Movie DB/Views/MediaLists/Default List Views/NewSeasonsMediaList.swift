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
        FilteredMediaList(list: PredicateMediaList.newSeasons, selectedMedia: $selectedMedia) { media in
            // TODO: Rework navigation
            NavigationLink(value: media) {
                LibraryRow()
                    .environmentObject(media)
            }
        }
    }
}

struct NewSeasonsMediaList_Previews: PreviewProvider {
    static var previews: some View {
        NewSeasonsMediaList(selectedMedia: .constant(PlaceholderData.movie))
    }
}
