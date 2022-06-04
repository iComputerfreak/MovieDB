//
//  FilteredMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilteredMediaList: View {
    let title: String
    let predicate: NSPredicate
    
    @FetchRequest
    private var medias: FetchedResults<Media>
    
    // swiftlint:disable:next type_contents_order
    init(list: MediaListProtocol) {
        self.title = list.name
        self.predicate = list.buildPredicate()
        self._medias = FetchRequest(
            entity: Media.entity(),
            // TODO: Support sorting
            sortDescriptors: [],
            predicate: predicate,
            animation: .default
        )
    }
    
    var body: some View {
        List {
            ForEach(medias) { media in
                LibraryRow()
                    .environmentObject(media)
            }
        }
        .navigationTitle(title)
    }
}

struct FilteredMediaList_Previews: PreviewProvider {
    static var previews: some View {
        FilteredMediaList(list: DefaultMediaList.favorites)
    }
}
