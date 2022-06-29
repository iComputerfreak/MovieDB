//
//  FilteredMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilteredMediaList<RowContent: View>: View {
    let list: MediaListProtocol
    let rowContent: (Media) -> RowContent
    
    @FetchRequest
    private var medias: FetchedResults<Media>
    
    // swiftlint:disable:next type_contents_order
    init(list: MediaListProtocol, rowContent: @escaping (Media) -> RowContent) {
        self.list = list
        self.rowContent = rowContent
        _medias = FetchRequest(fetchRequest: list.buildFetchRequest(), animation: .default)
    }
    
    var body: some View {
        VStack {
            // Show a warning when the filter is reset
            if let dynamicList = list as? DynamicMediaList, dynamicList.filterSetting?.isReset ?? false {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .symbolRenderingMode(.multicolor)
                    Text(Strings.Lists.filteredListResetWarning)
                }
            }
            
            if medias.isEmpty {
                Spacer()
                Text(Strings.Lists.filteredListEmptyMessage)
                Spacer()
            } else {
                List(medias) { media in
                    self.rowContent(media)
                }
                .listStyle(.plain)
                .navigationTitle(list.name)
            }
        }
    }
}

struct FilteredMediaList_Previews: PreviewProvider {
    static let dynamicList: DynamicMediaList = {
        _ = PlaceholderData.createMovie()
        let l = DynamicMediaList(context: PersistenceController.previewContext)
        l.name = "Dynamic List"
        l.iconName = "gear"
        return l
    }()
    
    static var previews: some View {
        let list = dynamicList
        NavigationStack {
            FilteredMediaList(list: list) { media in
                LibraryRow()
                    .environmentObject(media)
            }
            .navigationTitle(list.name)
            .environment(\.managedObjectContext, PersistenceController.previewContext)
        }
    }
}
