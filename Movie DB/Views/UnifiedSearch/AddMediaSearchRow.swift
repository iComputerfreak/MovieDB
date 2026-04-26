//
//  AddMediaSearchRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.26.
//  Copyright © 2026 Jonas Frey. All rights reserved.
//

import SwiftUI

struct AddMediaSearchRow: View {
    let result: TMDBSearchResult
    let addAction: () -> Void

    private var alreadyAdded: Bool {
        MediaLibrary.shared.mediaExists(result.id, mediaType: result.mediaType)
    }

    var body: some View {
        HStack(spacing: 12) {
            NavigationLink {
                LegacyMediaLookupDetail(tmdbID: result.id, mediaType: result.mediaType)
            } label: {
                SearchResultRow()
                    .environmentObject(result)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button(action: addAction) {
                Image(systemName: alreadyAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(alreadyAdded ? .green : .accentColor)
            }
            .buttonStyle(.borderless)
            .disabled(alreadyAdded)
            .accessibilityLabel(
                alreadyAdded
                ? Strings.AddMedia.addMediaButtonAlreadyAdded
                : Strings.AddMedia.addMediaButtonAddToLibrary
            )
        }
    }
}

#Preview {
    AddMediaSearchRow(result: PlaceholderData.preview.searchResultMovie, addAction: {})
        .previewEnvironment()
}
