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
    
    enum ActiveSheet: Identifiable {
        case addMedia
        case filter
        
        var id: Int { hashValue }
    }
    
    @ObservedObject private var library = MediaLibrary.shared
    @State private var activeSheet: ActiveSheet? = nil
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
                
                // Display the currently active sheet
                .sheet(item: $activeSheet) { sheet in
                    switch sheet {
                        case .addMedia:
                            AddMediaView()
                        case .filter:
                            FilterView()
                        // FUTURE: Open new item in editing mode
                        
                        //.sheet(item: $addedMedia, content: MediaDetail().environmentObject(_:))
                    }
                }
                
                .navigationBarItems(
                    //leading: Button(action: { self.activeSheet = .filter }, label: Text("Filter").closure()),
                    trailing: Button(action: { self.activeSheet = .addMedia }, label: Image(systemName: "plus").closure())
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
