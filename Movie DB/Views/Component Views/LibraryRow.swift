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
    let movieSymbol = NSLocalizedString("Movie").first!.lowercased() + ".square"
    let seriesSymbol = NSLocalizedString("Series").first!.lowercased() + ".square"
    
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
                                Image(systemName: "\(rating.label).square")
                                    .foregroundColor(rating.color ?? .primary)
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
struct ProblemsLibraryRow<T>: View where T: View {
    @EnvironmentObject var mediaObject: Media
    let content: T
    
    var body: some View {
        NavigationLink(destination: MediaDetail().environmentObject(mediaObject)) {
            HStack {
                Image(uiImage: mediaObject.thumbnail?.image, defaultImage: JFLiterals.posterPlaceholderName)
                    .thumbnail()
                VStack(alignment: .leading) {
                    Text(mediaObject.title)
                        .lineLimit(2)
                    // Under the title
                    HStack {
                        self.content
                    }
                }
            }
        }
    }
}

#if DEBUG
struct LibraryRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            LibraryRow()
                .environmentObject(PlaceholderData.movie as Media)
        }
    }
}
#endif
