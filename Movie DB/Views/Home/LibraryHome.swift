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
    @State private var isAddingMedia: Bool = false
    @State private var searchText: String = ""
    
    private var filteredMedia: [Media] {
        if searchText.isEmpty {
            return library.mediaList
        }
        return library.mediaList.filter({ $0.tmdbData?.title.contains(self.searchText) ?? false })
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
                            }
                        }
                    }
                }
            }
                
            .sheet(isPresented: $isAddingMedia, onDismiss: {
                self.isAddingMedia = false
            }, content: {
                AddMediaView(isAddingMedia: self.$isAddingMedia)
            })
                
                .navigationBarItems(leading: Button(action: {
                    print("Activating filter")
                }, label: {
                    //Image(systemName: "line.horizontal.3.decrease.circle")
                    Text("Filter")
                }), trailing:
                    Button(action: {
                        self.isAddingMedia = true
                    }, label: {
                        Image(systemName: "plus")
                    })
            )
                .navigationBarTitle(Text("Home"))
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
