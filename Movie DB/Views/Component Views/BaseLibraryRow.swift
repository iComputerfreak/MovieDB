//
//  BaseLibraryRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct BaseLibraryRow<SubtitleContent>: View where SubtitleContent: View {
    @EnvironmentObject var mediaObject: Media
    
    @ViewBuilder var subtitleContent: () -> SubtitleContent
    
    let movieSymbolText = Strings.Library.movieSymbolName
    let seriesSymbolText = Strings.Library.showSymbolName
    
    init(@ViewBuilder subtitleContent: @escaping () -> SubtitleContent = { EmptyView() }) {
        self.subtitleContent = subtitleContent
    }
    
    var body: some View {
        if mediaObject.isFault {
            // This will be displayed while the object is being deleted or is unavailable
            ProgressView()
        } else {
            HStack {
                // MARK: Thumbnail
                Image(uiImage: mediaObject.thumbnail, defaultImage: JFLiterals.posterPlaceholderName)
                    .thumbnail()
                VStack(alignment: .leading, spacing: 4) {
                    // MARK: Title
                    Text(mediaObject.title)
                        .lineLimit(2)
                        .font(.headline)
                    // Under the title
                    HStack {
                        // MARK: Type
                        switch mediaObject.type {
                        case .movie:
                            CapsuleLabelView(text: movieSymbolText)
                        case .show:
                            CapsuleLabelView(text: seriesSymbolText)
                        }
                        // MARK: Year
                        if let year = mediaObject.year {
                            CapsuleLabelView(text: year.description)
                        }
                        // MARK: FSK Rating
                        if let rating = mediaObject.parentalRating {
                            ParentalRatingView(rating: rating)
                                .font(.caption2)
                        }
                    }
                    .font(.subheadline)
                    // MARK: 3rd Row
                    subtitleContent()
                }
            }
        }
    }
}

struct BaseLibraryRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                BaseLibraryRow()
                    .environmentObject(PlaceholderData.preview.staticMovie as Media)
                BaseLibraryRow()
                    .environmentObject(PlaceholderData.preview.staticShow as Media)
            }
        }
    }
}
