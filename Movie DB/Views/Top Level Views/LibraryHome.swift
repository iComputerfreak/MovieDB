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
    // The filter setting
    @ObservedObject private var filterSetting = FilterSetting.shared
    
    @State private var activeSheet: ActiveSheet? = nil
    @State private var searchText: String = ""
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        // Use the proxy to scroll to a specific item after adding it
        ScrollViewReader { proxy in
            NavigationView {
                VStack {
                    // TODO: http://blog.eppz.eu/swiftui-search-bar-in-the-navigation-bar/
                    SearchBar(searchText: $searchText)
                    // We don't provide the searchText as a Binding to force a re-creation of the list whenever the searchText changes.
                    // This way, the fetchRequest inside LibraryList will be re-built every time the searchText changes
                    LibraryList(searchText: searchText, filterSetting: filterSetting)
                }
                
                // Display the currently active sheet
                .sheet(item: $activeSheet) { sheet in
                    switch sheet {
                        case .addMedia:
                            AddMediaView()
                                .environment(\.managedObjectContext, managedObjectContext)
                        case .filter:
                            FilterView()
                                .environment(\.managedObjectContext, managedObjectContext)
                        // FUTURE: Open new item in editing mode
                        //.sheet(item: $addedMedia, content: MediaDetail().environmentObject(_:))
                    }
                }
                
                .navigationBarItems(
                    leading: Button(action: {
                        self.activeSheet = .filter
                    }, label: {
                        // TODO: Symbol should change if filter is active. (line.horizontal.3.decrease.circle.fill)
                        // TODO: Press should toggle, long press should show view
                        Image(systemName: self.filterSetting.isReset ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                    }),
                    trailing: Button(action: {
                        self.activeSheet = .addMedia
                    }, label: {
                        Image(systemName: "plus")
                    }))
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
