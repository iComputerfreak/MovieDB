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
    
    var body: some View {
        NavigationLink(destination: MediaDetail().environmentObject(mediaObject)) {
            HStack {
                Image(uiImage: mediaObject.thumbnail, defaultImage: JFLiterals.posterPlaceholderName)
                    .thumbnail()
                VStack(alignment: .leading) {
                    Text(mediaObject.tmdbData?.title ?? "Loading...")
                        .lineLimit(2)
                    // Under the title
                    HStack {
                        // MARK: Adult
                        if mediaObject.isAdult ?? false {
                            Image(systemName: "a.square")
                        }
                        // MARK: Type
                        if mediaObject.type == .movie {
                            Image(systemName: "m.square")
                        } else {
                            Image(systemName: "s.square")
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

struct ProblemsLibraryRow<T>: View where T: View {
    
    @EnvironmentObject var mediaObject: Media
    let content: T
    
    var body: some View {
        NavigationLink(destination: MediaDetail().environmentObject(mediaObject)) {
            HStack {
                Image(uiImage: mediaObject.thumbnail, defaultImage: JFLiterals.posterPlaceholderName)
                    .thumbnail()
                VStack(alignment: .leading) {
                    Text(mediaObject.tmdbData?.title ?? "Loading...")
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
            .environmentObject(Media(type: .movie))
    }
}
#endif