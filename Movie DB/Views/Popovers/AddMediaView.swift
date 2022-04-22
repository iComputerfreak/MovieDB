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

struct AddMediaView: View {
    @ObservedObject private var library = MediaLibrary.shared
    @State private var results: [TMDBSearchResult] = []
    @State private var resultsText: String = ""
    @State private var searchText: String = ""
    @State private var isLoading = false
    @State private var isShowingProPopup = false
    @State private var pagesLoaded: Int = 0
    @State private var allPagesLoaded = true
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var cancellable: AnyCancellable?
    // The subject used to fire the searchText changed events
    private let searchTextChangedSubject = PassthroughSubject<String, Never>()
    
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
                            Button {
                                addMedia(result)
                            } label: {
                                SearchResultView(result: result)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        if !self.allPagesLoaded && !self.results.isEmpty {
                            Button {
                                loadMoreResults()
                            } label: {
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
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .onChange(of: self.searchText) { _ in
                    // If the user enters a search text, perform the search after a delay
                    searchTextChangedSubject.send(self.searchText)
                }
                
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
    
    func didAppear() {
        // Register for search text updates
        // We have to assign the publisher to a variable to it does not get deallocated and can be called with future changes
        self.cancellable = searchTextChangedSubject
            .print()
            // Wait 500 ms before actually searching for the text
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            // Remove duplicate calls
            .removeDuplicates()
            // The search text should have at least 3 characters
            .map { (searchText: String) -> String? in
                if searchText.isEmpty {
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
        // Check if title already exists in library
        let existingFetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        existingFetchRequest.predicate = NSPredicate(format: "%K = %@", "tmdbID", String(result.id))
        existingFetchRequest.fetchLimit = 1
        let existingObjects = (try? managedObjectContext.count(for: existingFetchRequest)) ?? 0
        // There should be no media objects with this tmdbID in the library
        guard existingObjects == 0 else {
            // Already added
            AlertHandler.showSimpleAlert(
                title: NSLocalizedString("Already Added"),
                message: NSLocalizedString("You already have '\(result.title)' in your library.")
            )
            return
        }
        // Pro limitations
        guard Utils.purchasedPro() || (MediaLibrary.shared.mediaCount() ?? 0) < JFLiterals.nonProMediaLimit else {
            // Show the Pro popup
            self.isShowingProPopup = true
            return
        }
        
        // Otherwise we can begin to load
        self.isLoading = true
        
        // Run async
        Task {
            do {
                // Try fetching the media object
                // Will be called on a background thread automatically, because TMDBAPI is an actor
                let media = try await TMDBAPI.shared.fetchMedia(
                    for: result.id,
                    type: result.mediaType,
                    context: managedObjectContext
                )
                
                // fetchMedia already created the Media object in a child context and saved it into the view context
                // All we need to do now is to load the thumbnail and update the UI
                await MainActor.run {
                    if let mainMedia = self.managedObjectContext.object(with: media.objectID) as? Media {
                        // We don't need to wait for the thumbnail to finish loading
                        Task {
                            // Call it on the media object in the viewContext, not on the mediaObject in the background context
                            await mainMedia.loadThumbnail()
                        }
                    } else {
                        print("Media object does not exist in the viewContext yet. Cannot load thumbnail.")
                    }
                    self.isLoading = false
                    // Dismiss the AddMediaView
                    self.presentationMode.wrappedValue.dismiss()
                }
            } catch let error as LocalizedError {
                print("Error loading media: \(error)")
                await MainActor.run {
                    AlertHandler.showSimpleAlert(
                        title: NSLocalizedString("Error"),
                        message: NSLocalizedString("Error loading media: \(error.localizedDescription)")
                    )
                    self.isLoading = false
                }
            } catch {
                print("Unknown Error: \(String(describing: error))")
                assertionFailure("This error should be captured specifically to give the user a more precise error " +
                                 "message.")
                await MainActor.run {
                    AlertHandler.showSimpleAlert(
                        title: NSLocalizedString("Error"),
                        message: NSLocalizedString("There was an error loading the media.")
                    )
                    self.isLoading = false
                }
            }
        }
    }
    
    func loadMoreResults() {
        // We cannot load results for an empty text
        guard !self.searchText.isEmpty else {
            return
        }
        // Fetch the additional search results async
        Task {
            do {
                let (results, totalPages) = try await TMDBAPI.shared.searchMedia(
                    searchText,
                    includeAdult: JFConfig.shared.showAdults,
                    fromPage: self.pagesLoaded + 1,
                    toPage: self.pagesLoaded + 2
                )
                
                // Clear "Loading..." from the first search
                await MainActor.run {
                    self.resultsText = ""
                }
                
                // Filter the search results
                let filteredResults = results
                    .filter { result in
                        // If we are showing adult movies, there is nothing to filter
                        // If the result is not a movie, we cannot check if it is "adult"
                        guard
                            JFConfig.shared.showAdults,
                            let movieResult = result as? TMDBMovieSearchResult
                        else {
                            return true
                        }
                        // We only include non-adult movies
                        return !movieResult.isAdult
                    }
                    // Remove search results with the same TMDB ID
                    .removingDuplicates(key: \.id)
                
                // Add the results to the list
                await MainActor.run {
                    self.results.append(contentsOf: filteredResults)
                    self.pagesLoaded += 1
                    // If we loaded all pages that are available, we can stop displaying the "Load more search results" button
                    self.allPagesLoaded = self.pagesLoaded >= totalPages
                    if filteredResults.isEmpty {
                        self.resultsText = NSLocalizedString("No results")
                    }
                }
            } catch TMDBAPI.APIError.pageOutOfBounds(_) {
                await MainActor.run {
                    // If the requested page was out of bounds, we stop displaying the "Load more results" button
                    self.allPagesLoaded = true
                }
            } catch {
                print("Error searching for media with searchText '\(searchText)': \(error)")
                await MainActor.run {
                    AlertHandler.showSimpleAlert(
                        title: NSLocalizedString("Error searching"),
                        message: NSLocalizedString("Error performing search: \(error.localizedDescription)")
                    )
                    self.results = []
                    self.resultsText = NSLocalizedString("Error loading search results")
                }
            }
        }
    }
    
    // TODO: Unused. Remove or find alternative way to get the correct year
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
struct AddMediaView_Previews: PreviewProvider {
    static var previews: some View {
        AddMediaView()
            .preferredColorScheme(.dark)
    }
}
#endif
