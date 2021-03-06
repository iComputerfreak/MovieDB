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
                            //JFUtils.fskLabel(JFUtils.FSKRating.allCases.randomElement()!)
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
struct LibraryRow_Previews : PreviewProvider {
    static var previews: some View {
        LibraryRow()
            .environmentObject(PlaceholderData.movie)
    }
}
#endif
