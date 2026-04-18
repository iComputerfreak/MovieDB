// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct MediaListEmptyState: View {
    let isSearching: Bool
    let isFiltered: Bool
    let customNothingHereYetDescription: String?
    let action: (() -> Void)?
    let resetFilterAction: (() -> Void)?

    init(
        isSearching: Bool,
        isFiltered: Bool,
        customNothingHereYetDescription: String? = nil,
        action: (() -> Void)? = nil,
        resetFilterAction: (() -> Void)? = nil
    ) {
        self.isSearching = isSearching
        self.isFiltered = isFiltered
        self.customNothingHereYetDescription = customNothingHereYetDescription
        self.action = action
        self.resetFilterAction = resetFilterAction
    }

    var body: some View {
        switch (isSearching, isFiltered) {
        case (true, true):
            searchEmptyState(description: Strings.Library.EmptyState.descriptionNoSearchAndFilterResults, showsFilterResetButton: true)

        case (true, false):
            searchEmptyState(description: Strings.Library.EmptyState.descriptionNoSearchResults)

        case (false, true):
            filteredEmptyState(resetFilterAction: resetFilterAction)

        case (false, false):
            ContentUnavailableView(
                Strings.Library.EmptyState.nothingHere,
                systemImage: "tray",
                description: Text(customNothingHereYetDescription ?? Strings.Library.EmptyState.descriptionNoContent)
            )
        }
    }

    func searchEmptyState(description: String, showsFilterResetButton: Bool = false) -> some View {
        ContentUnavailableView {
            Label(Strings.Library.EmptyState.noResults, systemImage: "magnifyingglass")
        } description: {
            Text(description)
        } actions: {
            if let action {
                Button(Strings.Library.EmptyState.searchInAddMedia, action: action)
                    .accessibilityIdentifier("library-empty-state-add-media-search")
            }
            if let resetFilterAction {
                Button(Strings.Library.EmptyState.resetFilter, action: resetFilterAction)
                    .accessibilityIdentifier("library-empty-state-reset-filter")
            }
        }
    }

    func filteredEmptyState(resetFilterAction: (() -> Void)?) -> some View {
        ContentUnavailableView {
            Label(Strings.Library.EmptyState.noResults, systemImage: "magnifyingglass")
        } description: {
            Text(Strings.Library.EmptyState.descriptionNoFilterResults)
        } actions: {
            if let resetFilterAction {
                Button(Strings.Library.EmptyState.resetFilter, action: resetFilterAction)
                    .accessibilityIdentifier("library-empty-state-reset-filter")
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

#Preview("Filtering with Reset Filter Button") {
    List {
        MediaListEmptyState(
            isSearching: false,
            isFiltered: true,
            resetFilterAction: {}
        )
    }
}

#Preview("No Media") {
    List {
        MediaListEmptyState(isSearching: false, isFiltered: false)
    }
}
