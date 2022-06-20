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
    
    let movieSymbol = Strings.Library.movieSymbolName
    let seriesSymbol = Strings.Library.showSymbolName
    
    var body: some View {
        if mediaObject.isFault {
            // This will be displayed while the object is being deleted
            EmptyView()
        } else {
            NavigationLink(destination: MediaDetail().environmentObject(mediaObject)) {
                HStack {
                    Image(uiImage: mediaObject.thumbnail, defaultImage: JFLiterals.posterPlaceholderName)
                        .thumbnail()
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mediaObject.title)
                            .lineLimit(2)
                            .font(.headline)
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
                        .font(.subheadline)
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
            Image(uiImage: mediaObject.thumbnail, defaultImage: JFLiterals.posterPlaceholderName)
                .thumbnail()
            VStack(alignment: .leading) {
                Text(mediaObject.title)
                    .lineLimit(2)
                    .font(.headline)
                // Under the title
                HStack {
                    Text(Strings.Problems.missingList(missing))
                        .font(.caption)
                        .italic()
                }
            }
        }
    }
}

struct LibraryRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                ForEach(ParentalRating.fskRatings, id: \.label) { rating in
                    let movie: Media = {
                        // swiftlint:disable:next force_cast
                        let movie = PlaceholderData.movie.copy() as! Movie
                        movie.parentalRating = rating
                        return movie
                    }()
                    LibraryRow()
                        .environmentObject(movie)
                }
                ProblemsLibraryRow()
                    .environmentObject(PlaceholderData.problemShow as Media)
            }
            .navigationTitle("Library")
        }
    }
}
