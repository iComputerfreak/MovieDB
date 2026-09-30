// Copyright © 2019 Jonas Frey. All rights reserved.

import SwiftUI

@available(*, deprecated, renamed: "MediaTitleView", message: "Use the iOS 26+ variant with a fallback.")
struct LegacyTitleView: View {
    @ObservedObject var media: Media
    
    var body: some View {
        if media.imagePath == nil {
            self.titleView
        } else {
            NavigationLink {
                LegacyPosterDetailView(imagePath: media.imagePath)
            } label: {
                self.titleView
            }
        }
    }
    
    private var titleView: some View {
        HStack(alignment: VerticalAlignment.center) {
            MediaPosterView(
                request: media.posterRequest,
                pointSize: CGSize(
                    width: JFLiterals.thumbnailSize.width * JFLiterals.detailThumbnailMultiplier,
                    height: JFLiterals.thumbnailSize.height * JFLiterals.detailThumbnailMultiplier
                )
            )
            .frame(
                width: JFLiterals.thumbnailSize.width * JFLiterals.detailThumbnailMultiplier,
                height: JFLiterals.thumbnailSize.height * JFLiterals.detailThumbnailMultiplier
            )
            .thumbnailStyle()
            .padding(.trailing)
            // Title and year
            VStack(alignment: .leading) {
                Text(media.title)
                    .font(.headline)
                    .lineLimit(3)
                    .padding([.bottom], 5.0)
                // MARK: Year and rating
                HStack {
                    if let year = media.year {
                        Text(year.description)
                            .foregroundColor(.gray)
                            .font(.headline)
                    }
                    if let rating = media.parentalRating {
                        ParentalRatingView(rating: rating)
                    }
                }
            }
        }
    }
}

#Preview(traits: .fixedLayout(width: 500, height: 250)) {
    NavigationStack {
        List {
            Section {
                LegacyTitleView(media: PlaceholderData.preview.staticMovie)
            }
        }
        .listStyle(.grouped)
    }
}
