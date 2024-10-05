//
//  LibraryHome.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Combine
import CoreData
import os.log
import SwiftUI

struct LibraryHome: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.editMode) private var editMode
    @State private var selectedMediaObjects: Set<Media> = .init()
    
    @State private var viewModel = LibraryViewModel()
    @ObservedObject private var filterSetting = FilterSetting.shared
    
    @State private var searchText: String = ""
    
    var totalMediaItems: Int {
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        return (try? managedObjectContext.count(for: fetchRequest)) ?? 0
    }
    
    var sortDescriptors: [NSSortDescriptor] {
        viewModel.sortingOrder.createSortDescriptors(with: viewModel.sortingDirection)
    }
    
    var predicate: NSPredicate {
        var predicates: [NSPredicate] = []
        if !searchText.isEmpty {
            predicates.append(NSPredicate(
                format: "(%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@)",
                Schema.Media.title.rawValue,
                searchText,
                Schema.Media.originalTitle.rawValue,
                searchText
            ))
        }
        predicates.append(filterSetting.buildPredicate())
        return NSCompoundPredicate(type: .and, subpredicates: predicates)
    }
    
    @FetchRequest(fetchRequest: Media.fetchRequest())
    var filteredMedia: FetchedResults<Media>
    
    init() {
        _filteredMedia = FetchRequest(
            sortDescriptors: sortDescriptors,
            predicate: predicate
        )
    }
    
    // TODO: Break up modifiers
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedMediaObjects) {
                Section(footer: footerText) {
                    ForEach(filteredMedia) { mediaObject in
                        NavigationLink(value: mediaObject) {
                            LibraryRow()
                                .mediaSwipeActions()
                                .mediaContextMenu()
                                .environmentObject(mediaObject)
                        }
                    }
                }
            }
            .environment(\.editMode, editMode)
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: Text(Strings.Library.searchPlaceholder))
            // Update the fetch request if anything changes
            .onChange(of: searchText) { _ in
                filteredMedia.nsPredicate = predicate
            }
            .onReceive(filterSetting.objectWillChange) {
                filteredMedia.nsPredicate = predicate
            }
            .onChange(of: viewModel.sortingOrder) { _ in
                filteredMedia.nsSortDescriptors = sortDescriptors
            }
            .onChange(of: viewModel.sortingDirection) { _ in
                filteredMedia.nsSortDescriptors = sortDescriptors
            }
            // Disable autocorrection in the search field as a workaround to search text changing after transitioning
            // to a detail and invalidating the transition
            .autocorrectionDisabled()
            // Display the currently active sheet
            .sheet(item: $viewModel.activeSheet) { sheet in
                switch sheet {
                case .addMedia:
                    AddMediaView()
                case .filter:
                    FilterView()
                }
            }
            .toolbar {
                LibraryToolbar(config: $viewModel, editMode: editMode, selectedMediaObjects: $selectedMediaObjects)
            }
            .navigationTitle(Strings.TabView.libraryLabel)
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Media.self) { mediaObject in
                MediaDetail()
                    .environmentObject(mediaObject)
            }
        } detail: {
            NavigationStack {
                if selectedMediaObjects.isEmpty {
                    EmptyView()
                } else if
                    selectedMediaObjects.count == 1,
                    let media = selectedMediaObjects.first
                {
                    MediaDetail()
                        .environmentObject(media)
                } else {
                    Text(Strings.Generic.multipleObjectsSelected)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .environmentObject(filterSetting)
    }
    
    var footerText: Text {
        guard !filteredMedia.isEmpty else {
            return Text(verbatim: "")
        }
        let objCount = filteredMedia.count
        
        // Showing all media
        if objCount == totalMediaItems {
            return Text(Strings.Library.footerTotal(objCount))
        } else {
            // Only showing a subset of the total medias
            return Text(Strings.Library.footer(objCount))
        }
    }
}

#Preview {
    LibraryHome()
        .previewEnvironment()
        .onAppear {
            PlaceholderData.preview.populateSamples()
        }
}
