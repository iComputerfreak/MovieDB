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
    @State private var selectedMediaObjects: Set<Media> = .init()
    
    @State private var config = LibraryViewConfig()
    @ObservedObject private var filterSetting = FilterSetting.shared
    
    @State private var searchText: String = ""
    
    var totalMediaItems: Int {
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        return (try? managedObjectContext.count(for: fetchRequest)) ?? 0
    }
    
    var sortDescriptors: [SortDescriptor<Media>] {
        config.sortingOrder.createSortDescriptors(with: config.sortingDirection)
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
            sortDescriptors: config.sortingOrder.createSortDescriptors(with: config.sortingDirection),
            predicate: predicate
        )
    }
    
    var body: some View {
        NavigationSplitView {
             List(selection: $selectedMediaObjects) {
                Section(footer: footerText) {
                    ForEach(filteredMedia) { mediaObject in
                        NavigationLink(value: mediaObject) {
                            LibraryRow()
                                .environmentObject(mediaObject)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(Strings.Library.swipeActionDelete, role: .destructive) {
                                        Logger.coreData.info(
                                            // swiftlint:disable:next line_length
                                            "Deleting \(mediaObject.title, privacy: .public) (mediaID: \(mediaObject.id?.uuidString ?? "nil", privacy: .public))"
                                        )
                                        // Thumbnail on will be deleted automatically by Media::prepareForDeletion()
                                        self.managedObjectContext.delete(mediaObject)
                                        PersistenceController.saveContext(self.managedObjectContext)
                                    }
                                }
                                .contextMenu {
                                    MediaMenu.AddToSection(mediaObject: mediaObject)
                                    MediaMenu.ActionsSection(mediaObject: mediaObject)
                                }
                        }
                    }
                }
            }
            .listStyle(.grouped)
            .searchable(text: $searchText, prompt: Text(Strings.Library.searchPlaceholder))
            // Update the fetch request if anything changes
            .onChange(of: searchText) { _ in
                filteredMedia.nsPredicate = predicate
            }
            .onReceive(filterSetting.objectWillChange) {
                filteredMedia.nsPredicate = predicate
            }
            .onChange(of: config.sortingOrder) { _ in
                filteredMedia.sortDescriptors = sortDescriptors
            }
            .onChange(of: config.sortingDirection) { _ in
                filteredMedia.sortDescriptors = sortDescriptors
            }
            // Disable autocorrection in the search field as a workaround to search text changing after transitioning
            // to a detail and invalidating the transition
            .autocorrectionDisabled()
            
            // Display the currently active sheet
            .sheet(item: $config.activeSheet) { sheet in
                switch sheet {
                case .addMedia:
                    AddMediaView()
                case .filter:
                    FilterView()
                }
            }
            .toolbar {
                LibraryToolbar(config: $config)
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
                } else if selectedMediaObjects.count == 1 {
                    let media = selectedMediaObjects.first!
                    MediaDetail()
                        .environmentObject(media)
                } else {
                    // TODO: Localize
                    Text("Multiple objects selected")
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

struct LibraryHome_Previews: PreviewProvider {
    static var previews: some View {
        LibraryHome()
            .environment(\.managedObjectContext, PersistenceController.previewContext)
            .onAppear {
                PlaceholderData.preview.populateSamples()
            }
    }
}
