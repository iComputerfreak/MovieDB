// Copyright © 2019 Jonas Frey. All rights reserved.

import os.log
import SwiftUI

struct SearchResultRow: View {
    /// The search result to display
    @EnvironmentObject private var result: TMDBSearchResult
    var alreadyInLibraryOverride: Bool?

    private var alreadyInLibrary: Bool {
        alreadyInLibraryOverride ?? MediaLibrary.shared.mediaExists(result.id, mediaType: result.mediaType)
    }

    private var imageURL: URL? {
        guard let imagePath = result.imagePath else { return nil }
        return Utils.getTMDBImageURL(path: imagePath, size: JFLiterals.thumbnailTMDBSize)
    }

    var year: Int? {
        if let releaseDate = (result as? TMDBMovieSearchResult)?.releaseDate {
            return releaseDate[.year]
        } else if let firstAirDate = (result as? TMDBShowSearchResult)?.firstAirDate {
            return firstAirDate[.year]
        }
        return nil
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // MARK: Thumbnail
            LoadableImageView(source: .url(imageURL))
                .frame(width: JFLiterals.thumbnailSize.width, height: JFLiterals.thumbnailSize.height)
                .thumbnailStyle()

            VStack(alignment: .leading, spacing: 4) {
                // MARK: Title
                Text(verbatim: "\(result.title)")
                    .lineLimit(2)
                    .font(.headline)
                // Under the title
                HStack {
                    // MARK: Type
                    MediaTypeCapsule(mediaType: result.mediaType)
                    // MARK: Year
                    if let year {
                        CapsuleLabelView(text: year.description)
                    }
                    // MARK: Adult
                    if result.isAdultMovie ?? false {
                        CapsuleLabelView(text: Strings.Library.libraryRowAdultString, color: .red)
                    }
                }
                .font(.subheadline)
                // MARK: Third Line: Already added
                if alreadyInLibrary {
                    Group {
                        Text(Image(systemName: "checkmark.circle.fill")) +
                        Text(verbatim: " ") +
                        Text(Strings.AddMedia.alreadyInLibraryLabelText)
                    }
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.green)
                }
            }
        }
    }
    
    func yearFromMediaResult(_ result: TMDBSearchResult) -> Date? {
        if result.mediaType == .movie {
            if let date = (result as? TMDBMovieSearchResult)?.releaseDate {
                return date
            }
        } else {
            if let date = (result as? TMDBShowSearchResult)?.firstAirDate {
                return date
            }
        }
        
        return nil
    }
}

#Preview("List") {
    NavigationStack {
        List {
            ForEach(
                [
                    PlaceholderData.preview.searchResultMovie,
                    PlaceholderData.preview.searchResultShow,
                    PlaceholderData.preview.searchResultMinimalMovie
                ],
                id: \.id
            ) { result in
                SearchResultRow()
                    .environmentObject(result)
            }
        }
        .navigationTitle(Text(verbatim: "Search Results"))
    }
    .previewEnvironment()
}

#Preview("Single", traits: .fixedLayout(width: 300, height: 100)) {
    SearchResultRow()
        .previewEnvironment()
        .environmentObject(PlaceholderData.preview.searchResultMovie)
}
