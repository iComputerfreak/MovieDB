//
//  AddMediaView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import CoreData
import struct JFSwiftUI.LoadingView

struct AddMediaView : View {
    
    @ObservedObject private var library = MediaLibrary.shared
    @State private var results: [TMDBSearchResult] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        LoadingView(isShowing: $isLoading) {
            NavigationView {
                VStack {
                    // FIX: For SOME reason, calling searchMedia() inside onCommit crashes the app. We have to call it from a button
                    SearchBar(searchText: $searchText, onCommit: {
                        DispatchQueue.global(qos: .userInitiated).async {
                            searchMedia()
                        }
                    })
                    
                    List {
                        ForEach(self.results, id: \.id) { (result: TMDBSearchResult) in
                            Button(action: { addMedia(result) }) {
                                SearchResultView(result: result)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.vertical)
                .navigationTitle(Text("Add Movie"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: { Image(systemName: "xmark") }))
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    func searchMedia() {
        print("Search: \(self.searchText)")
        guard !self.searchText.isEmpty else {
            self.results = []
            return
        }
        let api = TMDBAPI.shared
        api.searchMedia(self.searchText, includeAdult: JFConfig.shared.showAdults) { (results: [TMDBSearchResult]?, error: Error?) in
            
            if let error = error {
                print("Error searching for media with searchText '\(self.searchText)': \(error)")
                AlertHandler.showSimpleAlert(title: "Error searching", message: "Error performing search: \(error.localizedDescription)")
                return
            }
            
            guard let results = results else {
                print("Error searching for media with searchText '\(self.searchText)'")
                return
            }
                
            var filteredResults = results
            
            // Filter out adult media from the search results
            if !JFConfig.shared.showAdults {
                filteredResults = results.filter { (searchResult: TMDBSearchResult) in
                    // Only movie search results contain the adult flag
                    if let movieResult = searchResult as? TMDBMovieSearchResult {
                        return !movieResult.isAdult
                    }
                    return true
                }
            }
            // Remove search results with the same TMDB ID
            let duplicates = Dictionary(grouping: filteredResults, by: \.id).filter({ $0.value.count > 1 }).flatMap({ $0.value.dropFirst() })
            for duplicate in duplicates {
                // Delete duplicates from last to first
                let index = filteredResults.lastIndex(where: { $0.id == duplicate.id })
                filteredResults.remove(at: index!)
            }
            DispatchQueue.main.async {
                self.results = filteredResults
            }
        }
    }
    
    func addMedia(_ result: TMDBSearchResult) {
        print("Selected \(result.title)")
        if self.library.mediaList.contains(where: { $0.tmdbID == result.id }) {
            // Already added
            AlertHandler.showSimpleAlert(title: "Already added", message: "You already have '\(result.title)' in your library.")
        } else {
            self.isLoading = true
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try TMDBAPI.shared.fetchMediaAsync(id: result.id, type: result.mediaType) { (media: Media?, error: Error?) in
                        
                        if let error = error {
                            print("Error fetching media: \(error)")
                            return
                        }
                        
                        guard let bgMedia = media else {
                            print("Error fetching media. Media object is nil")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            do {
                                // Append the viewContext media object
                                try self.library.append(bgMedia)
                            } catch let e {
                                print("Error adding media '\(bgMedia.title)'")
                                print(e)
                                AlertHandler.showSimpleAlert(title: "Error", message: e.localizedDescription)
                            }
                            self.isLoading = false
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } catch let error as LocalizedError {
                    print("Error loading media: \(error)")
                    DispatchQueue.main.async {
                        AlertHandler.showSimpleAlert(title: "Error", message: "Error loading media: \(error.localizedDescription)")
                    }
                } catch let otherError {
                    print("Unknown Error: \(otherError)")
                    assertionFailure("This error should be captured specifically to give the user a more precise error message.")
                    DispatchQueue.main.async {
                        AlertHandler.showSimpleAlert(title: "Error", message: "There was an error loading the media.")
                    }
                }
            }
        }
    }
    
    func yearFromMediaResult(_ result: TMDBSearchResult) -> Int? {
        if result.mediaType == .movie {
            if let date = (result as? TMDBMovieSearchResult)?.releaseDate {
                return Calendar.current.component(.year, from: date)
            }
        } else {
            if let date = (result as? TMDBShowSearchResult)?.firstAirDate {
                return Calendar.current.component(.year, from: date)
            }
        }
        
        return nil
    }
}

#if DEBUG
struct AddMediaView_Previews : PreviewProvider {
    static var previews: some View {
        AddMediaView()
            .preferredColorScheme(.dark)
    }
}
#endif
