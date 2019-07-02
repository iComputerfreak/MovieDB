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
    
    @State private var media: [Media] = []
    
    func didAppear() {
        loadPlaceholderData()
    }
    
    func didDisappear() {
        
    }
    
    var body: some View {
        NavigationView {
                
            List(media) { media in
                LibraryRow(mediaObject: media)
            }
            
                .navigationBarItems(trailing: PresentationButton(destination: AddMediaView()) {
                    Image(systemName: "plus")
                })
                .navigationBarTitle(Text("Home"))
        }
            .onAppear(perform: self.didAppear)
            .onDisappear(perform: self.didDisappear)
    }
    
    func loadPlaceholderData() {
        var i = 0
        // Load some movies from TMDB to fill the library
        let api = TMDBAPI(apiKey: JFLiterals.apiKey.rawValue)
        let movies = ["John Wick 3", "The Matrix", "Brooklyn Nine Nine", "Inception", "World War Z", "Game of Thrones"]
        for movie in movies {
            let media = Media(id: i, tmdbData: nil, justWatchData: nil, type: .movie)
            i += 1
            // Get the id
            api.searchMedia(movie) { (results: [TMDBSearchResult]?) in
                guard let results = results else {
                    print("Error getting results for '\(movie)'")
                    return
                }
                // Add the first search result
                guard let id = results.first?.id else {
                    print("No results for '\(movie)'")
                    return
                }
                guard let type = results.first?.mediaType else {
                    print("Error getting type of the first media of '\(movie)'")
                    return
                }
                media.type = type
                print("\(movie): \(id)")
                if type == .movie {
                    // Get the movie details
                    api.getMovie(by: id) { (data) in
                        guard let data = data else {
                            print("Error getting details of '\(movie)'")
                            return
                        }
                        print("ID \(media.id) loaded TMDB Data (\(data.title))")
                        media.tmdbData = data
                    }
                } else {
                    // Get the show details
                    api.getShow(by: id) { (data) in
                        guard let data = data else {
                            print("Error getting details of '\(movie)'")
                            return
                        }
                        print("ID \(media.id) loaded TMDB Data (\(data.title))")
                        media.tmdbData = data
                    }
                }
            }
            self.media.append(media)
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
