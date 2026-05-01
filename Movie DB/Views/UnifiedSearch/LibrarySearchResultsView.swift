// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct LibrarySearchResultsView: View {
    let searchText: String
    let switchToAddMedia: () -> Void

    @FetchRequest private var mediaObjects: FetchedResults<Media>

    init(searchText: String, switchToAddMedia: @escaping () -> Void) {
        self.searchText = searchText
        self.switchToAddMedia = switchToAddMedia
        self._mediaObjects = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(
                    key: Schema.Media.title.rawValue,
                    ascending: true,
                    selector: #selector(NSString.localizedStandardCompare(_:))
                ),
            ],
            predicate: Self.predicate(for: searchText)
        )
    }

    var body: some View {
        Group {
            if searchText.isEmpty {
                UnifiedSearchPlaceholderView(
                    title: Strings.TabView.libraryLabel,
                    description: Strings.Library.searchPlaceholder
                )
            } else if mediaObjects.isEmpty {
                UnifiedSearchPlaceholderView(
                    title: Strings.Library.EmptyState.noResults,
                    description: Strings.Library.EmptyState.descriptionNoSearchResults,
                    buttonTitle: Strings.Library.EmptyState.searchInAddMedia,
                    action: switchToAddMedia
                )
            } else {
                List {
                    ForEach(mediaObjects) { mediaObject in
                        NavigationLink(value: mediaObject) {
                            LibraryRow()
                                .environmentObject(mediaObject)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    static func predicate(for searchText: String) -> NSPredicate {
        guard !searchText.isEmpty else { return NSPredicate(value: false) }

        return NSPredicate(
            format: "(%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@)",
            Schema.Media.title.rawValue,
            searchText,
            Schema.Media.originalTitle.rawValue,
            searchText
        )
    }
}

#Preview {
    NavigationStack {
        LibrarySearchResultsView(searchText: "Matrix") {}
    }
    .previewEnvironment()
}
