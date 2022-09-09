//
//  FilteredMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import SwiftUI

struct FilteredMediaList<RowContent: View>: View {
    let rowContent: (Media) -> RowContent
    let list: MediaListProtocol
    
    // Mirrors the respective property of the list for view updates
    @State private var sortingOrder: SortingOrder

    // Mirrors the respective property of the list for view updates
    @State private var sortingDirection: SortingDirection
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var mediaCount: Int {
        (try? managedObjectContext.count(for: list.buildFetchRequest())) ?? 0
    }
    
    // swiftlint:disable:next type_contents_order
    init(list: any MediaListProtocol, rowContent: @escaping (Media) -> RowContent) {
        self.rowContent = rowContent
        self.list = list
        _sortingOrder = State(wrappedValue: list.sortingOrder)
        _sortingDirection = State(wrappedValue: list.sortingDirection)
    }
    
    var body: some View {
        VStack {
            // Show a warning when the filter is reset
            if (list as? DynamicMediaList)?.filterSetting?.isReset ?? false {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .symbolRenderingMode(.multicolor)
                    Text(Strings.Lists.filteredListResetWarning)
                }
            }
            // Will be recreated every time the sorting order or direction changes
            SortableMediaList(
                sortingOrder: $sortingOrder,
                sortingDirection: $sortingDirection,
                fetchRequest: list.buildFetchRequest(),
                rowContent: self.rowContent
            )
            .onChange(of: sortingOrder) { newValue in
                // Update the actual list (either a CoreData entity or a default list)
                list.sortingOrder = newValue
            }
            .onChange(of: sortingDirection) { newValue in
                // Update the actual list (either a CoreData entity or a default list)
                list.sortingDirection = newValue
            }
        }
        .navigationTitle(list.name)
    }
}

struct SortableMediaList<RowContent: View>: View {
    @Binding var sortingOrder: SortingOrder
    @Binding var sortingDirection: SortingDirection
    let rowContent: (Media) -> RowContent
    
    @FetchRequest
    private var medias: FetchedResults<Media>
    
    // swiftlint:disable:next type_contents_order
    init(
        sortingOrder: Binding<SortingOrder>,
        sortingDirection: Binding<SortingDirection>,
        fetchRequest: NSFetchRequest<Media>,
        rowContent: @escaping (Media) -> RowContent
    ) {
        _sortingOrder = sortingOrder
        _sortingDirection = sortingDirection
        self.rowContent = rowContent
        
        // Update the sorting of the fetchRequest and use it to display the media
        let order = sortingOrder.wrappedValue
        let direction = sortingDirection.wrappedValue
        fetchRequest.sortDescriptors = order.createSortDescriptors(with: direction)
        _medias = FetchRequest(fetchRequest: fetchRequest, animation: .default)
    }
    
    var body: some View {
        if medias.isEmpty {
            Spacer()
            Text(Strings.Lists.filteredListEmptyMessage)
            Spacer()
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
        } else {
            List(medias) { media in
                self.rowContent(media)
            }
            .listStyle(.grouped)
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
