//
//  AddMediaView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import Combine
import struct JFSwiftUI.LoadingView

struct AddMediaView : View {
    
    @ObservedObject private var library = MediaLibrary.shared
    @State private var results: [TMDBSearchResult] = []
    @State private var resultsText: String = ""
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var isShowingProPopup: Bool = false
    @State private var pagesLoaded: Int = 0
    @State private var allPagesLoaded: Bool = true
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var publisher: AnyCancellable?
    
    @ObservedObject var searchBar: SearchBar = {
        let searchBar = SearchBar()
        searchBar.searchController.hidesNavigationBarDuringPresentation = false
        searchBar.searchController.automaticallyShowsCancelButton = false
        return searchBar
    }()
    
    func didAppear() {
        // Register for search text updates
        // We have to assign the publisher to a variable to it does not get deallocated and can be called with future changes
        self.publisher = self.searchBar.$text
            .print()
            // Wait 500 ms before actually searching for the text
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            // Remove duplicate calls
            .removeDuplicates()
            // The search text should have at least 3 characters
            .map { (searchText: String) -> String? in
                if searchText.count == 0 {
                    self.results = []
                    // Clear the search text (e.g. "No Results")
                    self.resultsText = ""
                }
                return searchText.count >= 3 ? searchText : nil
            }
            // Remove nil
            .compactMap { $0 }
            // Process the search text
            .sink { (searchText: String) in
                // Execute searchMedia when the search text changes
                self.searchMedia(searchText)
            }
    }
    
    var body: some View {
        LoadingView(isShowing: $isLoading) {
            NavigationView {
                List {
                    if self.results.isEmpty && !self.resultsText.isEmpty {
                        HStack {
                            Spacer()
                            Text(self.resultsText)
                                .italic()
                            Spacer()
                        }
                    } else {
                        ForEach(self.results) { (result: TMDBSearchResult) in
                            Button(action: { addMedia(result) }) {
                                SearchResultView(result: result)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        if !self.allPagesLoaded && !self.results.isEmpty {
                            Button(action: self.loadMoreResults) {
                                HStack {
                                    Spacer()
                                    Text("Load more results...")
                                        .italic()
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .add(searchBar)
                .navigationTitle(Text("Add Media"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: { Image(systemName: "xmark") }))
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onAppear(perform: didAppear)
        .popover(isPresented: $isShowingProPopup) {
            ProInfoView()
        }
    }
    
    func searchMedia(_ searchText: String) {
        print("Search: \(searchText)")
        guard !searchText.isEmpty else {
            self.results = []
            self.resultsText = ""
            return
        }
        self.searchText = searchText
        self.results = []
        self.pagesLoaded = 0
        self.resultsText = NSLocalizedString("Loading...")
        // Load the first page of results
        self.loadMoreResults()
    }
    
    func addMedia(_ result: TMDBSearchResult) {
        print("Selected \(result.title)")
        let existingFetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        existingFetchRequest.predicate = NSPredicate(format: "%K = %@", "tmdbID", String(result.id))
        existingFetchRequest.fetchLimit = 1
        let existingObjects = (try? managedObjectContext.count(for: existingFetchRequest)) ?? 0
        if existingObjects > 0 {
            // Already added
            AlertHandler.showSimpleAlert(title: NSLocalizedString("Already Added"), message: NSLocalizedString("You already have '\(result.title)' in your library."))
        } else {
            guard Utils.purchasedPro() || (MediaLibrary.shared.mediaCount() ?? 0) < JFLiterals.nonProMediaLimit else {
                // Show the Pro popup
                self.isShowingProPopup = true
                return
            }
            self.isLoading = true
            TMDBAPI.shared.fetchMediaAsync(id: result.id, type: result.mediaType, context: managedObjectContext) { (media: Media?, error: Error?) in
                
                if let error = error as? LocalizedError {
                    print("Error loading media: \(error)")
                    DispatchQueue.main.async {
                        AlertHandler.showSimpleAlert(title: NSLocalizedString("Error"), message: NSLocalizedString("Error loading media: \(error.localizedDescription)"))
                    }
                    self.isLoading = false
                    return
                } else if error != nil || media == nil {
                    print("Unknown Error: \(String(describing: error))")
                    assertionFailure("This error should be captured specifically to give the user a more precise error message.")
                    DispatchQueue.main.async {
                        AlertHandler.showSimpleAlert(title: NSLocalizedString("Error"), message: NSLocalizedString("There was an error loading the media."))
                    }
                    self.isLoading = false
                    return
                }
                
                // We don't have to do anything with the media object, since it already was added to the background context and the background context was saved.
                // The object will automatically be merged with the viewContext.
                DispatchQueue.main.async {
                    if let mainMedia = self.managedObjectContext.object(with: media!.objectID) as? Media {
                        // Call it on the media object in the viewContext, not on the mediaObject in the background context
                        mainMedia.loadThumbnailAsync()
                    } else {
                        print("Media object does not exist in the viewContext yet. Cannot load thumbnail.")
                    }
                    self.isLoading = false
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    func loadMoreResults() {
        // We cannot load results for an empty text
        guard !self.searchText.isEmpty else {
            return
        }
        let api = TMDBAPI.shared
        api.searchMedia(searchText, includeAdult: JFConfig.shared.showAdults, fromPage: self.pagesLoaded + 1, toPage: self.pagesLoaded + 2) { (results: [TMDBSearchResult]?, totalPages: Int?, error: Error?) in
            
            // Clear "Loading..." from the first search
            self.resultsText = ""
            
            // If the requested page was out of bounds, we stop displaying the "Load more results" button
            if let error = error as? TMDBAPI.APIError, error == TMDBAPI.APIError.pageOutOfBounds {
                self.allPagesLoaded = true
                return
            }
            
            if let error = error {
                print("Error searching for media with searchText '\(searchText)': \(error)")
                AlertHandler.showSimpleAlert(title: NSLocalizedString("Error searching"), message: NSLocalizedString("Error performing search: \(error.localizedDescription)"))
                self.results = []
                self.resultsText = NSLocalizedString("Error loading search results")
                return
            }
            
            guard let results = results else {
                print("Error searching for media with searchText '\(searchText)'")
                self.results = []
                self.resultsText = NSLocalizedString("Error loading search results")
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
                self.results.append(contentsOf: filteredResults)
                self.pagesLoaded += 1
                // If we loaded all pages that are available, we can stop displaying the "Load more search results" button
                self.allPagesLoaded = totalPages.map({ self.pagesLoaded >= $0 }) ?? false
                if filteredResults.isEmpty {
                    self.resultsText = NSLocalizedString("No results")
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
