//
//  SearchResultsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

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
    /// Fallback state property when the caller gave no binding to use
    @State private var searchText: String
    @State private var isLoadingNextPage: Bool = false
    @Binding var selection: TMDBSearchResult?
    let prompt: Text
    let searchTextBinding: Binding<String>?
    let autoFocus: Bool
    let showsSearchBar: Bool

    @EnvironmentObject private var config: JFConfig
    
    /// The action to execute when one of the results is pressed
    let content: (TMDBSearchResult) -> RowContent

    var activeSearchText: Binding<String> {
        if let searchTextBinding {
            searchTextBinding
        } else {
            $searchText
        }
    }

    init(
        selection: Binding<TMDBSearchResult?>,
        prompt: Text,
        initialSearchText: String = "",
        autoFocus: Bool = false,
        @ViewBuilder content: @escaping (TMDBSearchResult) -> RowContent
    ) {
        self.content = content
        self.prompt = prompt
        self._selection = selection
        self.autoFocus = autoFocus
        self.showsSearchBar = true
        self.searchTextBinding = nil
        self._searchText = State(initialValue: initialSearchText)
    }

    init(
        searchText: Binding<String>,
        selection: Binding<TMDBSearchResult?>,
        prompt: Text,
        showsSearchBar: Bool,
        autoFocus: Bool = false,
        @ViewBuilder content: @escaping (TMDBSearchResult) -> RowContent
    ) {
        self.content = content
        self.prompt = prompt
        self._selection = selection
        self.autoFocus = autoFocus
        self.showsSearchBar = showsSearchBar
        self.searchTextBinding = searchText
        self._searchText = State(initialValue: searchText.wrappedValue)
    }
    
    var body: some View {
        VStack {
            if showsSearchBar {
                // !!!: We don't use .searchable here to prevent the "Cancel" button from covering the "Done" button and confusing the user
                JFSearchBar(text: activeSearchText, prompt: prompt, autoFocus: autoFocus)
            }
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
                                ProgressView()
                                    .opacity(isLoadingNextPage ? 1 : 0)
                                Text(Strings.MediaSearch.loadMore)
                            }
                        }
                    }
                }
            }
        }
        .onAppear { synchronizeExternalSearchText() }
        .onChange(of: activeSearchText.wrappedValue) { _, searchText in
            if showsSearchBar {
                synchronizeExternalSearchText(with: searchText)
            }
        }
        .task(id: activeSearchText.wrappedValue) {
            await searchTask(for: activeSearchText.wrappedValue)
        }
    }

    func synchronizeExternalSearchText(with value: String? = nil) {
        let value = value ?? self.searchText

        guard
            let searchTextBinding,
            searchTextBinding.wrappedValue != value
        else { return }

        searchTextBinding.wrappedValue = value
    }

    func searchTask(for rawSearchText: String) async {
        let searchText = rawSearchText.trimmingCharacters(in: .whitespacesAndNewlines)

        Logger.addMedia.debug("Searching for: \(searchText, privacy: .public)")

        guard !searchText.isEmpty else {
            await MainActor.run {
                clearResults()
            }
            return
        }

        guard searchText.count >= 3 else {
            await MainActor.run {
                clearResults()
            }
            return
        }

        do {
            try await Task.sleep(for: .milliseconds(500))
        } catch {
            return
        }

        guard !Task.isCancelled else { return }

        await MainActor.run {
            searchMedia(searchText)
        }
    }

    func clearResults() {
        results = []
        resultsText = ""
        pagesLoaded = 0
        allPagesLoaded = true
    }

    func searchMedia(_ searchText: String) {
        Logger.addMedia.info("Searching for: \(searchText, privacy: .public)")
        results = []
        pagesLoaded = 0
        allPagesLoaded = true
        guard !searchText.isEmpty else { return }
        // Load the first page of results
        resultsText = Strings.MediaSearch.loading
        loadNextPage(for: searchText)
    }
    
    func loadNextPage(for rawSearchText: String? = nil) {
        let rawSearchText = rawSearchText ?? activeSearchText.wrappedValue
        let searchText = rawSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        // We cannot load results for an empty text
        guard !searchText.isEmpty else { return }

        self.isLoadingNextPage = true
        // Fetch the additional search results async
        Task(priority: .userInitiated) {
            do {
                let (results, totalPages) = try await TMDBAPI.shared.searchMedia(
                    searchText,
                    includeAdult: config.showAdults,
                    from: self.pagesLoaded + 1,
                    to: self.pagesLoaded + 2
                )

                let currentSearchText = activeSearchText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
                guard currentSearchText == searchText else {
                    await MainActor.run {
                        self.isLoadingNextPage = false
                    }
                    // Search text changed since we started, abort
                    return
                }

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
                        else { return true }
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
                    "Error searching for media with searchText '\(searchText, privacy: .public)': \(error, privacy: .public)"
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

            await MainActor.run {
                self.isLoadingNextPage = false
            }
        }
    }
}

#Preview("Results") {
    NavigationStack {
        SearchResultsView(selection: .constant(nil), prompt: Text(verbatim: "Search..."), initialSearchText: "asd") { result in
            SearchResultRow()
                .environmentObject(result)
        }
        .navigationTitle(Text(verbatim: "Add Media"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Text(verbatim: "Done")
                }
            }
        }
    }
    .previewEnvironment()
}

#Preview("Empty") {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                SearchResultsView(selection: .constant(nil), prompt: Text(verbatim: "Search...")) { result in
                    SearchResultRow()
                        .environmentObject(result)
                }
                .navigationTitle(Text(verbatim: "Add Media"))
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {} label: {
                            Text(verbatim: "Done")
                        }
                    }
                }
            }
        }
        .previewEnvironment()
}
