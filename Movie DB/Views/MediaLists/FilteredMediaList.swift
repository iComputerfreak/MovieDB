//
//  FilteredMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import SwiftUI

struct FilteredMediaList<RowContent: View, ListType>: View where ListType: MediaListProtocol & ObservableObject {
    let rowContent: (Media) -> RowContent
    @ObservedObject var list: ListType
    let description: String?
    let filter: ((Media) -> Bool)?
    
    // Mirrors the respective property of the list for view updates
    @State private var sortingOrder: SortingOrder

    // Mirrors the respective property of the list for view updates
    @State private var sortingDirection: SortingDirection
    
    @State private var showingInfo = false
    
    @Binding var selectedMedia: Media?
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var mediaCount: Int {
        (try? managedObjectContext.count(for: list.buildFetchRequest())) ?? 0
    }
    
    init(
        list: ListType,
        selectedMedia: Binding<Media?>,
        rowContent: @escaping (Media) -> RowContent
    ) {
        self.rowContent = rowContent
        self.list = list
        if let predicateList = list as? PredicateMediaList {
            self.filter = predicateList.filter
            self.description = predicateList.description
        } else {
            self.filter = nil
            self.description = nil
        }
        _sortingOrder = State(wrappedValue: list.sortingOrder)
        _sortingDirection = State(wrappedValue: list.sortingDirection)
        _selectedMedia = selectedMedia
    }
    
    var body: some View {
        VStack {
            // Show a warning when the filter is reset
            if (list as? DynamicMediaList)?.filterSetting?.isReset ?? false {
                CalloutView(text: Strings.Lists.filteredListResetWarning, type: .warning)
                    .padding(.horizontal, 8)
            }
            // Will be recreated every time the sorting order or direction changes
            SortableMediaList(
                sortingOrder: $sortingOrder,
                sortingDirection: $sortingDirection,
                fetchRequest: list.buildFetchRequest(),
                selectedMedia: $selectedMedia,
                filter: self.filter,
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
        .toolbar {
            if let description {
                Button {
                    self.showingInfo = true
                } label: {
                    Label("Info", systemImage: "info.circle")
                }
                .alert(list.name, isPresented: $showingInfo) {
                    Button("Ok") {}
                } message: {
                    Text(description)
                }
            }
        }
        .navigationTitle(list.name)
    }
}

struct FilteredMediaList_Previews: PreviewProvider {
    static let dynamicList: DynamicMediaList = {
        PlaceholderData.preview.populateSamples()
        let l = DynamicMediaList(context: PersistenceController.previewContext)
        l.name = "Dynamic List"
        l.iconName = "gear"
        return l
    }()
    
    static var previews: some View {
        NavigationStack {
            FilteredMediaList(list: dynamicList, selectedMedia: .constant(nil)) { media in
                LibraryRow()
                    .environmentObject(media)
            }
            .navigationTitle(dynamicList.name)
            .environment(\.managedObjectContext, PersistenceController.previewContext)
        }
    }
}
