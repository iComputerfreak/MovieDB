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
    
    @EnvironmentObject private var library: MediaLibrary
    @State private var isAddingMedia: Bool = false
    
    var body: some View {
        NavigationView {
            
            List {
                ForEach(library.mediaList) { mediaObject in
                    NavigationLink(destination:
                        MediaDetail()
                            .environmentObject(mediaObject)
                    ) {
                        LibraryRow()
                            .environmentObject(mediaObject)
                    }
                }
                .onDelete { self.library.mediaList.remove(atOffsets: $0) }
            }
                
            .sheet(isPresented: $isAddingMedia, onDismiss: {
                self.isAddingMedia = false
            }, content: {
                AddMediaView(isAddingMedia: self.$isAddingMedia).environmentObject(self.library)
            })
                
                .navigationBarItems(trailing:
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
            .environmentObject(PlaceholderData.mediaLibrary)
    }
}
#endif
