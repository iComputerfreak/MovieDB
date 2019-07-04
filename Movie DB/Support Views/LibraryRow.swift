//
//  LibraryRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct LibraryRow : View {
    
    @State var mediaObject: Media
    
    var body: some View {
        HStack {
            if (mediaObject.thumbnail != nil) {
                // Thumbnail image
                Image(uiImage: mediaObject.thumbnail!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: JFLiterals.thumbnailSize.width, height: JFLiterals.thumbnailSize.height, alignment: .center)
            } else {
                // Placeholder image
                Image(systemName: (mediaObject.type == .movie ? "film" : "tv"))
                    .resizable()
                    .aspectRatio((mediaObject.type == .movie ? 0.9 : 1.0), contentMode: .fit)
                    .padding(5)
                    .frame(width: JFLiterals.thumbnailSize.width, height: JFLiterals.thumbnailSize.height, alignment: .center)
            }
            VStack(alignment: .leading) {
                Text(mediaObject.tmdbData?.title ?? "Loading...")
                if mediaObject.isAdult ?? false {
                    Image(systemName: "a.square")
                }
                if mediaObject.type == .movie {
                    Image(systemName: "m.square")
                } else {
                    Image(systemName: "s.square")
                }
            }
        }
    }
}

#if DEBUG
struct LibraryRow_Previews : PreviewProvider {
    static var previews: some View {
        LibraryRow(mediaObject: Media(type: .movie))
    }
}
#endif
