//
//  LibraryHome.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import Combine
import JFSwiftUI

struct LibraryHome : View {
    
    @ObservedObject private var library = MediaLibrary.shared
    @ObservedObject private var filterSettings = FilterSettings.shared
    @State private var isAddingMedia: Bool = false
    @State private var isShowingFilterOptions: Bool = false
    @State private var searchText: String = ""
    @State private var sortedAlphabetically = true
    
    private var filteredMedia: [Media] {
        var list = library.mediaList
        // MARK: Search Term
        if !searchText.isEmpty {
            list = list.filter({ media in
                if media.tmdbData?.title.contains(self.searchText) ?? false {
                    return true
                }
                if media.tmdbData?.originalTitle.contains(self.searchText) ?? false {
                    return true
                }
                // Partial matches
                if media.keywords.contains(where: { $0.contains(self.searchText) }) {
                    return true
                }
                // Partial matches
                if media.cast.map({ $0.name }).contains(where: { $0.contains(self.searchText) }) {
                    return true
                }
                if media.notes.contains(self.searchText) {
                    return true
                }
                // Exact tag matches only
                if media.tags.map({ TagLibrary.shared.name(for: $0) }).contains(self.searchText) {
                    return true
                }
                if let idString = media.tmdbData?.id {
                    if String(idString) == self.searchText {
                        return true
                    }
                }
                return false
            })
        }
        // Additionally to the filter, hide adult media, if not explicitly set in config
        if !JFConfig.shared.showAdults {
            // Include media where isAdult is not set
            list = list.filter({ !($0.isAdult ?? false) })
        }
        // MARK: Sorting
        if sortedAlphabetically {
            list = list.sorted(by: { (media1, media2) in
                if media1.tmdbData == nil {
                    return false
                } else if media2.tmdbData == nil {
                    return true
                }
                return media1.tmdbData!.title.lexicographicallyPrecedes(media2.tmdbData!.title)
            })
        }
        // Apply the filter
        return self.filterSettings.apply(on: list)
    }
    
    func didAppear() {
        
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $searchText)
                List {
                    ForEach(filteredMedia) { mediaObject in
                        NavigationLink(destination:
                            MediaDetail()
                                .environmentObject(mediaObject)
                        ) {
                            LibraryRow()
                                .environmentObject(mediaObject)
                        }
                    }
                    .onDelete { indexSet in
                        for offset in indexSet {
                            let id = self.filteredMedia[offset].id
                            DispatchQueue.main.async {
                                self.library.mediaList.removeAll(where: { $0.id == id })
                                self.library.save()
                            }
                        }
                    }
                }
            }
                
                // FUTURE: Workaround for using two sheet modifiers
                .background(
                    EmptyView()
                        .sheet(isPresented: $isAddingMedia) { AddMediaView() }
                        .background(
                            EmptyView()
                                .sheet(isPresented: $isShowingFilterOptions) { FilterView() }
                        )
                )
                
                .navigationBarItems(leading:
                    Button(action: { self.isShowingFilterOptions = true }, label: Text("Filter").closure()), trailing:
                    Button(action: { self.isAddingMedia = true }, label: Image(systemName: "plus").closure())
                )
                .navigationBarTitle(Text("Home"))
        }
        .onAppear(perform: didAppear)
    }
}

#if DEBUG
struct LibraryHome_Previews : PreviewProvider {
    static var previews: some View {
        LibraryHome()
    }
}
#endif
