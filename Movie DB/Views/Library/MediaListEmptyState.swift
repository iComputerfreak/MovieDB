// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct MediaListEmptyState: View {
    let isSearching: Bool
    let isFiltered: Bool
    let customNothingHereYetDescription: String?
    let action: (() -> Void)?

    init(
        isSearching: Bool,
        isFiltered: Bool,
        customNothingHereYetDescription: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.isSearching = isSearching
        self.isFiltered = isFiltered
        self.customNothingHereYetDescription = customNothingHereYetDescription
        self.action = action
    }

    var body: some View {
        switch (isSearching, isFiltered) {
        case (true, true):
            searchEmptyState(description: Strings.Library.EmptyState.descriptionNoSearchAndFilterResults)

        case (true, false):
            searchEmptyState(description: Strings.Library.EmptyState.descriptionNoSearchResults)

        case (false, true):
            ContentUnavailableView(
                Strings.Library.EmptyState.noResults,
                systemImage: "magnifyingglass",
                description: Text(Strings.Library.EmptyState.descriptionNoFilterResults)
            )

        case (false, false):
            ContentUnavailableView(
                Strings.Library.EmptyState.nothingHere,
                systemImage: "tray",
                description: Text(customNothingHereYetDescription ?? Strings.Library.EmptyState.descriptionNoContent)
            )
        }
    }

    func searchEmptyState(description: String) -> some View {
        ContentUnavailableView {
            Label(Strings.Library.EmptyState.noResults, systemImage: "magnifyingglass")
        } description: {
            Text(description)
        } actions: {
            if let action {
                Button(Strings.Library.EmptyState.searchInAddMedia, action: action)
                    .accessibilityIdentifier("library-empty-state-add-media-search")
            }
        }
    }
}

#Preview("Searching, Filtering") {
    NavigationStack {
        List {}
            .navigationTitle("List")
            .refreshable {}
            .searchable(text: .constant("Search text"))
            .overlay {
                MediaListEmptyState(isSearching: true, isFiltered: true, action: {})
            }
    }
}

#Preview("Searching") {
    List {
        MediaListEmptyState(isSearching: true, isFiltered: false, action: {})
    }
}

#Preview("Filtering") {
    List {
        MediaListEmptyState(isSearching: false, isFiltered: true)
    }
}

#Preview("No Media") {
    List {
        MediaListEmptyState(isSearching: false, isFiltered: false)
    }
}
