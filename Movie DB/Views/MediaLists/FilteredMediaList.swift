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
    let filter: (Media) -> Bool
    
    // Mirrors the respective property of the list for view updates
    @State private var sortingOrder: SortingOrder
    // Mirrors the respective property of the list for view updates
    @State private var sortingDirection: SortingDirection
    
    @State private var showingInfo = false
    @Binding var selectedMedia: Media?
    
    @FetchRequest
    private var medias: FetchedResults<Media>
    
    // The filtered and sorted medias
    var filteredMedias: [Media] {
        var medias = Array(medias)
        // If the list defines a custom filter, apply it
        if let filter = list.customFilter {
            medias = medias.filter(filter)
        }
        // If the list overrides the sorting options, use the custom sorting
        if let sorting = list.customSorting {
            medias = medias.sorted(by: sorting)
        }
        return medias
    }
    
    init(
        list: ListType,
        selectedMedia: Binding<Media?>,
        rowContent: @escaping (Media) -> RowContent
    ) {
        self.rowContent = rowContent
        self.list = list
        self.filter = list.customFilter ?? { _ in true }
        _sortingOrder = State(wrappedValue: list.sortingOrder)
        _sortingDirection = State(wrappedValue: list.sortingDirection)
        _selectedMedia = selectedMedia
        _medias = FetchRequest(fetchRequest: list.buildFetchRequest())
    }
    
    var body: some View {
        VStack {
            // Show a warning when the filter of a dynamic list is reset
            emptyDynamicListWarning
            // Filtered media should not be empty
            if filteredMedias.isEmpty {
                HStack {
                    Spacer()
                    Text(Strings.Lists.filteredListEmptyMessage)
                    Spacer()
                }
            } else {
                List(filteredMedias, selection: $selectedMedia) { media in
                    self.rowContent(media)
                        .tag(media)
                }
                .listStyle(.grouped)
            }
        }
        .onChange(of: sortingOrder) { newValue in
            // Update the actual list (either a CoreData entity or a default list)
            list.sortingOrder = newValue
            $medias.nsSortDescriptors.wrappedValue = newValue.createNSSortDescriptors(with: self.sortingDirection)
        }
        .onChange(of: sortingDirection) { newValue in
            // Update the actual list (either a CoreData entity or a default list)
            list.sortingDirection = newValue
            $medias.nsSortDescriptors.wrappedValue = self.sortingOrder.createNSSortDescriptors(with: newValue)
        }
        .toolbar {
            toolbarInfoButton
            toolbarSortingButton
        }
        .navigationTitle(list.name)
    }
    
    @ViewBuilder
    var emptyDynamicListWarning: some View {
        if (list as? DynamicMediaList)?.filterSetting?.isReset ?? false {
            CalloutView(text: Strings.Lists.filteredListResetWarning, type: .warning)
                .padding(.horizontal, 8)
        }
    }
    
    @ToolbarContentBuilder
    var toolbarInfoButton: some ToolbarContent {
        if let description = list.listDescription {
            ToolbarItem(placement: .navigationBarTrailing) {
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
    }
    
    @ToolbarContentBuilder
    var toolbarSortingButton: some ToolbarContent {
        // Only show the user the option to sort, if the list does not define a static sorting
        if list.customSorting == nil {
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

#Preview {
    let dynamicList: DynamicMediaList = {
        PlaceholderData.preview.populateSamples()
        let l = DynamicMediaList(context: PersistenceController.previewContext)
        l.name = "Dynamic List"
        l.iconName = "gear"
        return l
    }()
    
    return NavigationStack {
        FilteredMediaList(list: dynamicList, selectedMedia: .constant(nil)) { media in
            LibraryRow()
                .environmentObject(media)
        }
        .navigationTitle(dynamicList.name)
        .environment(\.managedObjectContext, PersistenceController.previewContext)
    }
}
