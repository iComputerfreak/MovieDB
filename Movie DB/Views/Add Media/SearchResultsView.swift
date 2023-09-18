//
//  SearchResultsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Combine
import CoreData
import JFSwiftUI
import os.log
import SwiftUI

/// A view that allows the user to search for TMDB movies/shows
///
/// The `SearchResultsView` displays the search results and executes the given action when one of the results is pressed.
struct SearchResultsView<RowContent: View>: View {
    @State private var results: [TMDBSearchResult] = []
    @State private var resultsText: String = ""
    @State private var pagesLoaded: Int = 0
    @State private var allPagesLoaded = true
    @Binding var selection: TMDBSearchResult?
    let prompt: Text?
    
    // We use an observable model to store the searchText and publisher
    // This way, we can access the publisher of the @Published searchText property directly to
    // perform the searches and we have a mutable place to store the publisher of type AnyCancellable?
    @StateObject private var model: SearchResultsModel = .init()
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    @EnvironmentObject private var config: JFConfig
    
    /// The action to execute when one of the results is pressed
    let content: (TMDBSearchResult) -> RowContent
    
    init(
        selection: Binding<TMDBSearchResult?>,
        prompt: Text? = nil,
        @ViewBuilder content: @escaping (TMDBSearchResult) -> RowContent
    ) {
        self.content = content
        self.prompt = prompt
        self._selection = selection
    }
    
    var body: some View {
        List(selection: $selection) {
            if self.results.isEmpty, !self.resultsText.isEmpty {
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
                if !self.allPagesLoaded, !self.results.isEmpty {
                    Button {
                        loadNextPage()
                    } label: {
                        HStack {
                            Spacer()
                            Text(Strings.MediaSearch.loadMore)
                                .italic()
                            Spacer()
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .onAppear(perform: onAppear)
        .searchable(text: $model.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: prompt)
    }
    
    func onAppear() {
        // Register the publisher for the search results
        model.publisher = model.$searchText
            .receive(on: RunLoop.main)
            .map { searchText in
                Logger.addMedia.debug("Searching for: \(searchText, privacy: .public)")
                return searchText
            }
            // Wait 500 ms before actually searching for the text
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            // Remove duplicate calls
            .removeDuplicates()
            // The search text should have at least 3 characters
            .map { (searchText: String) -> String? in
                if searchText.isEmpty {
                    self.results = []
                    // Clear the search result text (e.g. "No Results")
                    self.resultsText = ""
                }
                return searchText.count >= 3 ? searchText : nil
            }
            // Remove nil
            .compactMap { $0 }
            // Execute searchMedia when the search text changes
            .sink(receiveValue: searchMedia)
    }
    
    func searchMedia(_ searchText: String) {
        Logger.addMedia.info("Searching for: \(searchText, privacy: .public)")
        model.searchText = searchText
        results = []
        pagesLoaded = 0
        guard !searchText.isEmpty else {
            return
        }
        // Load the first page of results
        resultsText = Strings.MediaSearch.loading
        loadNextPage()
    }
    
    func loadNextPage() {
        // We cannot load results for an empty text
        guard !model.searchText.isEmpty else {
            return
        }
        // Fetch the additional search results async
        Task(priority: .userInitiated) {
            do {
                let (results, totalPages) = try await TMDBAPI.shared.searchMedia(
                    model.searchText,
                    includeAdult: config.showAdults,
                    from: self.pagesLoaded + 1,
                    to: self.pagesLoaded + 2
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
                            config.showAdults,
                            let movieResult = result as? TMDBMovieSearchResult
                        else {
                            return true
                        }
                        // We only include non-adult movies
                        return !movieResult.isAdult
                    }
                    // Remove search results with the same TMDB ID
                    .uniqued(on: \.id)
                
                // Add the results to the list
                await MainActor.run {
                    self.results.append(contentsOf: filteredResults)
                    self.pagesLoaded += 1
                    // If we loaded all pages that are available, we can stop displaying the "Load more search results" button
                    self.allPagesLoaded = self.pagesLoaded >= totalPages
                    if filteredResults.isEmpty {
                        self.resultsText = Strings.MediaSearch.noResults
                    }
                }
            } catch TMDBAPI.APIError.pageOutOfBounds(_) {
                await MainActor.run {
                    // If the requested page was out of bounds, we stop displaying the "Load more results" button
                    self.allPagesLoaded = true
                }
            } catch {
                Logger.addMedia.error(
                    // swiftlint:disable:next line_length
                    "Error searching for media with searchText '\(model.searchText, privacy: .public)': \(error, privacy: .public)"
                )
                await MainActor.run {
                    AlertHandler.showError(
                        title: Strings.MediaSearch.Alert.errorSearchingTitle,
                        error: error
                    )
                    self.results = []
                    self.resultsText = Strings.MediaSearch.errorText
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchResultsView(selection: .constant(nil)) { result in
            SearchResultRow(result: result)
        }
        .navigationTitle(Text(verbatim: "Add Media"))
    }
}

// The model that stores the publisher-related properties for the search
class SearchResultsModel: ObservableObject {
    @Published var searchText: String = ""
    var publisher: AnyCancellable?
}
