//
//  LibraryHome.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import Combine

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
                if media.tmdbData?.title.lowercased().contains(self.searchText.lowercased()) ?? false {
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
                if media.cast.map(\.name).contains(where: { $0.contains(self.searchText) }) {
                    return true
                }
                if media.notes.contains(self.searchText) {
                    return true
                }
                // Exact tag matches only
                if media.tags.map(TagLibrary.shared.name).contains(self.searchText) {
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
                /// Removes the first word, if it is contained in the list of words that are ignored for sorting. If the first two words match, it leaves the title unchanged.
                func removeWordsIgnoredForSorting(_ title: String) -> String {
                    let words = title.components(separatedBy: .whitespaces)
                    // Only remove the first word. If the title starts with multiple words that would be ignored for sorting, remove none
                    if let word1 = words.first, JFUtils.wordsIgnoredForSorting.contains(word1) {
                        if words.count > 1 && !JFUtils.wordsIgnoredForSorting.contains(words[1]) {
                            // Only the first word matched. Remove it (incl. the spaces)
                            return title.removingPrefix(word1).trimmingCharacters(in: .whitespaces)
                        }
                    }
                    return title
                }
                // Remove any leading "the"; capitalization does not matter for sorting
                let name1 = removeWordsIgnoredForSorting(media1.tmdbData!.title.lowercased())
                let name2 = removeWordsIgnoredForSorting(media2.tmdbData!.title.lowercased())
                
                return name1.lexicographicallyPrecedes(name2)
            })
        }
        // Apply the filter
        return self.filterSettings.applied(on: list)
    }
    
    func didAppear() {
        
    }
    
    var body: some View {
        ScrollViewReader { proxy in
        NavigationView {
            VStack {
                SearchBar(searchText: $searchText)
                    List {
                        Section(footer: Text("\(filteredMedia.count) object\(filteredMedia.count == 1 ? "" : "s")\(filteredMedia.count == library.mediaList.count ? " total" : "")")) {
                            ForEach(filteredMedia) { mediaObject in
                                LibraryRow()
                                    .environmentObject(mediaObject)
                            }
                            .onDelete { indexSet in
                                for offset in indexSet {
                                    let id = self.filteredMedia[offset].id
                                    self.library.remove(id: id)
                                }
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                }
                
                // FUTURE: Workaround for using two sheet modifiers
                .background(
                    EmptyView()
                        .sheet(isPresented: $isAddingMedia) { AddMediaView() }
                        .background(
                            EmptyView()
                                .sheet(isPresented: $isShowingFilterOptions) { FilterView() }
                                .background(
                                    EmptyView()
                                        // TODO: Change to full screen side view
                                        
                                        //.sheet(item: $addedMedia, content: MediaDetail().environmentObject(_:))
                                )
                        )
                )
                
                .navigationBarItems(leading:
                    Button(action: { self.isShowingFilterOptions = true }, label: Text("Filter").closure()), trailing:
                    Button(action: { self.isAddingMedia = true }, label: Image(systemName: "plus").closure())
                )
                .navigationBarTitle(Text("Home"))
        }
        .onAppear(perform: didAppear)
        .onDisappear {
            self.library.save()
        }
        }
    }
}

#if DEBUG
struct LibraryHome_Previews : PreviewProvider {
    static var previews: some View {
        LibraryHome()
    }
}
#endif
