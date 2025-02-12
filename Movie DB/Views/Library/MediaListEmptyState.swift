// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct MediaListEmptyState: View {
    let isSearching: Bool
    let isFiltered: Bool

    var body: some View {
        switch (isSearching, isFiltered) {
        case (true, true):
            ContentUnavailableView(
                Strings.Library.EmptyState.noResults,
                systemImage: "magnifyingglass",
                description: Text(Strings.Library.EmptyState.descriptionNoSearchAndFilterResults)
            )

        case (true, false):
            ContentUnavailableView(
                Strings.Library.EmptyState.noResults,
                systemImage: "magnifyingglass",
                description: Text(Strings.Library.EmptyState.descriptionNoSearchResults)
            )

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
                description: Text(Strings.Library.EmptyState.descriptionNoContent)
            )
        }
    }
}

#Preview("Searching, Filtering") {
    NavigationStack {
        List {}
            .listStyle(.grouped)
            .navigationTitle("List")
            .refreshable {}
            .searchable(text: .constant("Search text"))
            .overlay {
                MediaListEmptyState(isSearching: true, isFiltered: true)
            }
    }
}

#Preview("Searching") {
    List {
        MediaListEmptyState(isSearching: true, isFiltered: false)
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
