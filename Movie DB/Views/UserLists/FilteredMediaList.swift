//
//  FilteredMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilteredMediaList<RowContent: View>: View {
    let title: String
    let rowContent: (Media) -> RowContent
    
    @FetchRequest
    private var medias: FetchedResults<Media>
    
    // swiftlint:disable:next type_contents_order
    init(list: MediaListProtocol, rowContent: @escaping (Media) -> RowContent) {
        self.title = list.name
        self.rowContent = rowContent
        self._medias = FetchRequest(fetchRequest: list.buildFetchRequest(), animation: .default)
    }
    
    var body: some View {
        // TODO: Show text when no entries
        // TODO: Show different text when filter is reset ("please configure filter")
        List {
            ForEach(medias) { media in
                self.rowContent(media)
            }
        }
        .listStyle(.plain)
        .navigationTitle(title)
    }
}

struct FilteredMediaList_Previews: PreviewProvider {
    static var previews: some View {
        FilteredMediaList(list: DefaultMediaList.favorites) { media in
            LibraryRow()
                .environmentObject(media)
        }
    }
}
