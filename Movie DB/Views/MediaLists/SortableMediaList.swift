//
//  SortableMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.10.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import SwiftUI

struct SortableMediaList<RowContent: View>: View {
    @Binding var sortingOrder: SortingOrder
    @Binding var sortingDirection: SortingDirection
    let rowContent: (Media) -> RowContent
    
    @FetchRequest
    private var medias: FetchedResults<Media>
    
    @Binding var selectedMedia: Media?
    
    // swiftlint:disable:next type_contents_order
    init(
        sortingOrder: Binding<SortingOrder>,
        sortingDirection: Binding<SortingDirection>,
        fetchRequest: NSFetchRequest<Media>,
        selectedMedia: Binding<Media?>,
        rowContent: @escaping (Media) -> RowContent
    ) {
        self._sortingOrder = sortingOrder
        self._sortingDirection = sortingDirection
        self._selectedMedia = selectedMedia
        self.rowContent = rowContent
        
        // Update the sorting of the fetchRequest and use it to display the media
        let order = sortingOrder.wrappedValue
        let direction = sortingDirection.wrappedValue
        fetchRequest.sortDescriptors = order.createSortDescriptors(with: direction)
        _medias = FetchRequest(fetchRequest: fetchRequest, animation: .default)
    }
    
    var body: some View {
        Group {
            if medias.isEmpty {
                Spacer()
                Text(Strings.Lists.filteredListEmptyMessage)
                Spacer()
            } else {
                List(medias, selection: $selectedMedia) { media in
                    self.rowContent(media)
                        .tag(media)
                }
                .listStyle(.grouped)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    SortingMenuSection(
                        sortingOrder: $sortingOrder,
                        sortingDirection: $sortingDirection
                    )
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                }
            }
        }
    }
}

struct SortableMediaList_Previews: PreviewProvider {
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
            SortableMediaList(
                sortingOrder: .constant(list.sortingOrder),
                sortingDirection: .constant(list.sortingDirection),
                fetchRequest: list.buildFetchRequest(),
                selectedMedia: .constant(nil)
            ) { media in
                LibraryRow()
                    .environmentObject(media)
            }
            .navigationTitle(list.name)
            .environment(\.managedObjectContext, PersistenceController.previewContext)
        }
    }
}
