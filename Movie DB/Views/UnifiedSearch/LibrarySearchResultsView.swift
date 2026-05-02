// Copyright © 2026 Jonas Frey. All rights reserved.

import Analytics
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
                ScreenUnavailableView(
                    title: Strings.TabView.libraryLabel,
                    systemImage: "magnifyingglass",
                    description: Strings.Library.searchPlaceholder
                )
            } else if mediaObjects.isEmpty {
                ScreenUnavailableView(
                    title: Strings.Library.EmptyState.noResults,
                    systemImage: "magnifyingglass",
                    description: Strings.Library.EmptyState.descriptionNoSearchResults,
                    actionTitle: Strings.Library.EmptyState.searchInAddMedia,
                    actionSystemImage: "magnifyingglass",
                    action: {
                        AnalyticsService.shared.track(
                            .emptyStateActionUsed(action: .searchInAddMedia, screen: .librarySearchResults)
                        )
                        switchToAddMedia()
                    }
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
