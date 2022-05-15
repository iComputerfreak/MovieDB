//
//  LibraryRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct LibraryRow: View {
    @EnvironmentObject var mediaObject: Media
    
    // Use the localized word for "movie" or "series" and take the first character of that
    // TODO: We may not have a correct symbol for every possible language... Maybe build our own view like with ratings
    let movieSymbol = String(
        localized: "library.list.movieSymbol",
        comment: "A SF Symbols name describing a movie (e.g. 'm.square'). Used in the library list beneath the name."
    )
    let seriesSymbol = String(
        localized: "library.list.showSymbol",
        // swiftlint:disable:next line_length
        comment: "A SF Symbols name describing a series/tv show (e.g. 's.square'). Used in the library list beneath the name."
    )
    
    var body: some View {
        if mediaObject.isFault {
            // This will be displayed while the object is being deleted
            Text("")
        } else {
            NavigationLink(destination: MediaDetail().environmentObject(mediaObject)) {
                HStack {
                    Image(uiImage: mediaObject.thumbnail?.image, defaultImage: JFLiterals.posterPlaceholderName)
                        .thumbnail()
                    VStack(alignment: .leading) {
                        Text(mediaObject.title)
                            .lineLimit(2)
                        // Under the title
                        HStack {
                            // MARK: Type
                            if mediaObject.type == .movie {
                                Image(systemName: movieSymbol)
                            } else {
                                Image(systemName: seriesSymbol)
                            }
                            // MARK: FSK Rating
                            if let rating = mediaObject.parentalRating {
                                rating.symbol
                                    .font(.caption2)
                            }
                            // MARK: Year
                            if mediaObject.year != nil {
                                Text(mediaObject.year!.description)
                            }
                        }
                    }
                }
            }
        }
    }
}

// swiftlint:disable:next file_types_order
struct ProblemsLibraryRow: View {
    @EnvironmentObject var mediaObject: Media
    var missing: String {
        mediaObject.missingInformation()
            .map(\.localized)
            .sorted()
            .joined(separator: ", ")
    }
    
    var body: some View {
        HStack {
            Image(uiImage: mediaObject.thumbnail?.image, defaultImage: JFLiterals.posterPlaceholderName)
                .thumbnail()
            VStack(alignment: .leading) {
                Text(mediaObject.title)
                    .lineLimit(2)
                // Under the title
                HStack {
                    Text("Missing: \(missing)")
                        .font(.caption)
                        .italic()
                }
            }
        }
    }
}

struct LibraryRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            LibraryRow()
                .environmentObject(PlaceholderData.movie as Media)
            ProblemsLibraryRow()
                .environmentObject(PlaceholderData.problemShow as Media)
        }
    }
}
