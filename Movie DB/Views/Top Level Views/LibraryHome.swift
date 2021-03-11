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
    @State private var isAddingMedia: Bool = false
    @State private var isShowingFilterOptions: Bool = false
    @State private var searchText: String = ""
    
    var body: some View {
        // Use the proxy to scroll to a specific item after adding it
        ScrollViewReader { proxy in
            NavigationView {
                VStack {
                    SearchBar(searchText: $searchText)
                    // We don't provide the searchText as a Binding to force a re-creation of the list whenever the searchText changes.
                    // This way, the fetchRequest inside LibraryList will be re-built every time the searchText changes
                    LibraryList(searchText: searchText)
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
                                    // FUTURE: Open new item in editing mode
                                    
                                    //.sheet(item: $addedMedia, content: MediaDetail().environmentObject(_:))
                                )
                        )
                )
                
                .navigationBarItems(leading: Button(action: { self.isShowingFilterOptions = true }, label: Text("Filter").closure()),
                                    trailing: Button(action: { self.isAddingMedia = true }, label: Image(systemName: "plus").closure())
                )
                .navigationBarTitle(Text("Home"))
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
