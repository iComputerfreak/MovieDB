// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct AddMediaSearchRow: View {
    let result: TMDBSearchResult
    let addAction: () async -> Bool

    @State private var didAddMedia = false

    private var alreadyAdded: Bool {
        didAddMedia || MediaLibrary.shared.mediaExists(result.id, mediaType: result.mediaType)
    }

    var body: some View {
        HStack(spacing: 12) {
            Button {
                Task(priority: .userInitiated) {
                    guard await addAction() else { return }
                    await MainActor.run {
                        didAddMedia = true
                    }
                }
            } label: {
                Image(systemName: alreadyAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(alreadyAdded ? .green : .accentColor)
            }
            .buttonStyle(.borderless)
            .disabled(alreadyAdded)
            .accessibilityIdentifier("add-media-search-row-button")
            .accessibilityLabel(
                alreadyAdded
                ? Strings.AddMedia.addMediaButtonAlreadyAdded
                : Strings.AddMedia.addMediaButtonAddToLibrary
            )

            NavigationLink {
                MediaLookupDetail(tmdbID: result.id, mediaType: result.mediaType)
            } label: {
                SearchResultRow(alreadyInLibraryOverride: alreadyAdded)
                    .environmentObject(result)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            didAddMedia = MediaLibrary.shared.mediaExists(result.id, mediaType: result.mediaType)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            AddMediaSearchRow(result: PlaceholderData.preview.searchResultMovie) { false }
            AddMediaSearchRow(result: PlaceholderData.preview.searchResultShow) { false }
        }
        .task {
            try? await MediaLibrary.shared.addMedia(PlaceholderData.preview.searchResultShow)
        }
    }
    .previewEnvironment()
}
