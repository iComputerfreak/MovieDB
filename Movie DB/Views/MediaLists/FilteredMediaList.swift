//
//  FilteredMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import SwiftUI

struct FilteredMediaList<
    RowContent: View,
    ListType: MediaListProtocol & ObservableObject,
    ExtraMenuItemContent: View
>: View {
    @ObservedObject var list: ListType
    let filter: (Media) -> Bool
    let rowContent: (Media) -> RowContent
    let extraMoreMenuItems: () -> ExtraMenuItemContent

    @Environment(\.editMode) private var editMode

    @State private var searchText = ""
    // Mirrors the respective property of the list for view updates
    @State private var sortingOrder: SortingOrder
    // Mirrors the respective property of the list for view updates
    @State private var sortingDirection: SortingDirection

    @State private var showingInfo = false
    @Binding private var selectedMediaObjects: Set<Media>
    
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
        // If the user entered a search text, use it for filtering as well
        if !searchText.isEmpty {
            medias = medias.filter { media in
                let foldedSearchText = searchText.folding(
                    options: [.caseInsensitive, .diacriticInsensitive],
                    locale: .current
                )
                let foldedTitle = media.title.folding(
                    options: [.caseInsensitive, .diacriticInsensitive],
                    locale: .current
                )
                let foldedOriginalTitle = media.originalTitle.folding(
                    options: [.caseInsensitive, .diacriticInsensitive],
                    locale: .current
                )

                return foldedTitle.contains(foldedSearchText) || foldedOriginalTitle.contains(foldedSearchText)
            }
        }
        return medias
    }

    var descriptionText: String? {
        switch list {
        case is DynamicMediaList:
            return nil

        case is UserMediaList:
            return Strings.Lists.customListEmptyStateDescription

        case is PredicateMediaList:
            return Strings.Lists.filteredListEmptyMessage

        default:
            return nil
        }
    }

    init(
        list: ListType,
        selectedMediaObjects: Binding<Set<Media>>,
        @ViewBuilder rowContent: @escaping (Media) -> RowContent,
        @ViewBuilder extraMoreMenuItems: @escaping () -> ExtraMenuItemContent = { EmptyView() }
    ) {
        self.list = list
        self.filter = list.customFilter ?? { _ in true }
        self.rowContent = rowContent
        self.extraMoreMenuItems = extraMoreMenuItems
        _sortingOrder = State(wrappedValue: list.sortingOrder)
        _sortingDirection = State(wrappedValue: list.sortingDirection)
        _selectedMediaObjects = selectedMediaObjects
        _medias = FetchRequest(fetchRequest: list.buildFetchRequest())
    }
    
    var body: some View {
        VStack {
            // Show a warning when the filter of a dynamic list is reset
            emptyDynamicListWarning
            // Filtered media should not be empty
            List(selection: $selectedMediaObjects) {
                Section {
                    ForEach(filteredMedias) { media in
                        rowContent(media)
                            .tag(media)
                    }
                } footer: {
                    // Show total objects at the bottom of the list
                    if !filteredMedias.isEmpty {
                        Text(Strings.Library.footer(filteredMedias.count))
                    }
                }
            }
            .listStyle(.grouped)
            .animation(.default, value: editMode?.wrappedValue)
            .searchable(text: $searchText, prompt: Text(Strings.Library.searchPlaceholder))
            // Disable autocorrection in the search field as a workaround to search text changing after transitioning
            // to a detail and invalidating the transition
            .autocorrectionDisabled()
            .overlay {
                MediaListEmptyState(
                    isSearching: false,
                    isFiltered: list is DynamicMediaList,
                    customNothingHereYetDescription: descriptionText
                )
                .opacity(filteredMedias.isEmpty ? 1 : 0)
            }
        }
        .onChange(of: sortingOrder) { _, newValue in
            // Update the actual list (either a CoreData entity or a default list)
            list.sortingOrder = newValue
            $medias.nsSortDescriptors.wrappedValue = newValue.createNSSortDescriptors(with: self.sortingDirection)
        }
        .onChange(of: sortingDirection) { _, newValue in
            // Update the actual list (either a CoreData entity or a default list)
            list.sortingDirection = newValue
            $medias.nsSortDescriptors.wrappedValue = self.sortingOrder.createNSSortDescriptors(with: newValue)
        }
        .toolbar {
            toolbarInfoButton
            toolbarMoreButton
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
                    Label(Strings.Lists.infoButtonLabel, systemImage: "info.circle")
                }
                .alert(list.name, isPresented: $showingInfo) {
                    Button(Strings.Generic.alertButtonOk) {}
                } message: {
                    Text(description)
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolbarMoreButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                MultiSelectionMenu(selectedMediaObjects: $selectedMediaObjects, allMediaObjects: Set(medias))
                // The section will only be rendered, if it actually has content, so we don't need an extra `if` here
                Section {
                    extraMoreMenuItems()
                }
                // Only show the user the option to sort, if the list does not define a static sorting
                if list.customSorting == nil {
                    SortingMenuSection(
                        sortingOrder: $sortingOrder,
                        sortingDirection: $sortingDirection
                    )
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

#Preview {
    let dynamicList: DynamicMediaList = {
        PlaceholderData.preview.populateSamples()
        let l = DynamicMediaList(context: PersistenceController.xcodePreviewContext)
        l.name = "Dynamic List"
        l.iconName = "gear"
        return l
    }()
    
    NavigationStack {
        FilteredMediaList(list: dynamicList, selectedMediaObjects: .constant([])) { media in
            LibraryRow(subtitleContent: .watchState)
                .environmentObject(media)
        }
        .navigationTitle(dynamicList.name)
        .environment(\.managedObjectContext, PersistenceController.xcodePreviewContext)
    }
}
