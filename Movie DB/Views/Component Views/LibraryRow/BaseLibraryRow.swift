// Copyright © 2023 Jonas Frey. All rights reserved.

import SwiftUI

struct BaseLibraryRow<SubtitleContent>: View where SubtitleContent: View {
    enum LibraryRowCapsule: String {
        case mediaType
        case releaseYear
        case parentalRating
        case isAdultMedia
        case isFavorite
        case isOnWatchlist
    }
    
    @EnvironmentObject var mediaObject: Media
    
    @ViewBuilder var subtitleContent: () -> SubtitleContent
    
    private var capsules: [LibraryRowCapsule]

    init(
        capsules: [LibraryRowCapsule] = [.mediaType, .releaseYear, .parentalRating, .isAdultMedia],
        @ViewBuilder subtitleContent: @escaping () -> SubtitleContent
    ) {
        self.capsules = capsules
        self.subtitleContent = subtitleContent
    }

    init(
        capsules: [LibraryRowCapsule] = [.mediaType, .releaseYear, .parentalRating, .isAdultMedia]
    ) where SubtitleContent == EmptyView {
        self.init(capsules: capsules, subtitleContent: { EmptyView() })
    }

    var body: some View {
        if mediaObject.isFault {
            // This will be displayed while the object is being deleted or is unavailable
            ProgressView()
        } else {
            HStack {
                // MARK: Thumbnail
                Group {
                    if let thumbnail = mediaObject.thumbnail {
                        Image(uiImage: thumbnail)
                            .thumbnailStyle()
                    } else {
                        PosterPlaceholderView.thumbnail()
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    // MARK: Title
                    Text(mediaObject.title)
                        .lineLimit(2)
                        .font(.headline)
                    // Under the title
                    WrappingHStack {
                        ForEach(capsules, id: \.rawValue) { capsule in
                            buildView(for: capsule)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                    // MARK: 3rd Row
                    subtitleContent()
                }
            }
        }
    }
    
    @ViewBuilder
    private func buildView(for capsule: LibraryRowCapsule) -> some View {
        switch capsule {
        case .mediaType:
            MediaTypeCapsule(mediaType: mediaObject.type)
            
        case .releaseYear:
            if let year = mediaObject.year {
                CapsuleLabelView(text: year.description)
            }
            
        case .parentalRating:
            if let rating = mediaObject.parentalRating {
                ParentalRatingView(rating: rating)
            }
            
        case .isAdultMedia:
            if (mediaObject as? Movie)?.isAdult ?? false {
                CapsuleLabelView(text: Strings.Library.libraryRowAdultString, color: .red)
            }
            
        case .isFavorite:
            if mediaObject.isFavorite {
                CapsuleLabelView(preserveMinimumHeight: true) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                }
            }
            
        case .isOnWatchlist:
            if mediaObject.isOnWatchlist {
                CapsuleLabelView {
                    PredicateMediaList.watchlist.icon
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            BaseLibraryRow()
                .environmentObject(PlaceholderData.preview.staticMovie as Media)
            BaseLibraryRow()
                .environmentObject(PlaceholderData.preview.staticShow as Media)
        }
    }
}
