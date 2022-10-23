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
    let list: any MediaListProtocol
    
    // Mirrors the respective property of the list for view updates
    @State private var sortingOrder: SortingOrder

    // Mirrors the respective property of the list for view updates
    @State private var sortingDirection: SortingDirection
    
    @Binding var selectedMedia: Media?
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var mediaCount: Int {
        (try? managedObjectContext.count(for: list.buildFetchRequest())) ?? 0
    }
    
    // swiftlint:disable:next type_contents_order
    init(list: any MediaListProtocol, selectedMedia: Binding<Media?>, rowContent: @escaping (Media) -> RowContent) {
        self.rowContent = rowContent
        self.list = list
        _sortingOrder = State(wrappedValue: list.sortingOrder)
        _sortingDirection = State(wrappedValue: list.sortingDirection)
        _selectedMedia = selectedMedia
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
                selectedMedia: $selectedMedia,
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
            FilteredMediaList(list: list, selectedMedia: .constant(nil)) { media in
                LibraryRow()
                    .environmentObject(media)
            }
            .navigationTitle(list.name)
            .environment(\.managedObjectContext, PersistenceController.previewContext)
        }
    }
}
