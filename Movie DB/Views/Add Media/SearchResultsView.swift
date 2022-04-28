//
//  SearchResultsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI
import JFSwiftUI
import Combine

/// A view that allows the user to search for TMDB movies/shows
///
/// The `SearchResultsView` displays the search results and executes the given action when one of the results is pressed.
struct SearchResultsView<RowContent: View>: View {
    @State private var results: [TMDBSearchResult] = []
    @State private var resultsText: String = ""
    @State private var searchText: String = ""
    @State private var pagesLoaded: Int = 0
    @State private var allPagesLoaded = true
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var cancellable: AnyCancellable?
    // The subject used to fire the searchText changed events
    private let searchTextChangedSubject = PassthroughSubject<String, Never>()

    /// The action to execute when one of the results is pressed
    let content: (TMDBSearchResult) -> RowContent
    
    // swiftlint:disable:next type_contents_order
    init(@ViewBuilder content: @escaping (TMDBSearchResult) -> RowContent) {
        self.content = content
    }
    
    var body: some View {
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
                    content(result)
                }
                if !self.allPagesLoaded && !self.results.isEmpty {
                    Button {
                        loadNextPage()
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
        .onAppear(perform: didAppear)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: self.searchText) { newValue in
            // If the user enters a search text, perform the search after a delay
            searchTextChangedSubject.send(newValue)
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
        self.searchText = searchText
        self.results = []
        self.pagesLoaded = 0
        guard !searchText.isEmpty else {
            return
        }
        // Load the first page of results
        self.resultsText = NSLocalizedString("Loading...")
        self.loadNextPage()
    }
    
    func loadNextPage() {
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

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchResultsView { result in
                SearchResultRow(result: result)
            }
            .navigationTitle("Add Media")
        }
    }
}
