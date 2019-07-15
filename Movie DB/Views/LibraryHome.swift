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
    
    func didAppear() {
        //loadPlaceholderData()
    }
    
    func didDisappear() {
        
    }
    
    var body: some View {
        NavigationView {
                
            List(library.mediaList) { mediaObject in
                NavigationLink(destination: MediaDetail(mediaObject: mediaObject)) {
                    LibraryRow(mediaObject: mediaObject)
                }
            }
            .presentation(isAddingMedia ? Modal(AddMediaView(isAddingMedia: $isAddingMedia).environmentObject(library), onDismiss: {
                self.isAddingMedia = false
                print("Dismissed")
            }) : nil)
            
                .navigationBarItems(/*leading:
                    Button(action: {
                        self.library.mediaList = []
                        self.loadPlaceholderData()
                    }, label: {
                        Text("Reset")
                    }), */trailing:
                    Button(action: {
                        self.isAddingMedia = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                )
                .navigationBarTitle(Text("Home"))
        }
            .onAppear(perform: self.didAppear)
            .onDisappear(perform: self.didDisappear)
    }
    
    func loadPlaceholderData() {
        // Load some movies from TMDB to fill the library
        let api = TMDBAPI(apiKey: JFLiterals.apiKey)
        let movies = ["John Wick 3", "The Matrix", "Brooklyn Nine Nine", "Inception", "World War Z", "Game of Thrones", "How to Get Away with Murder", "Scandal"]
        for movie in movies {
            api.searchMedia(movie) { (results: [TMDBSearchResult]?) in
                guard let results = results else {
                    print("Error getting results for '\(movie)'")
                    return
                }
                // Add the first search result
                guard let first = results.first else {
                    print("No results for '\(movie)'")
                    return
                }
                let media = Media(from: first)
                print("\(movie): \(first.id)")
                self.library.mediaList.append(media)
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
