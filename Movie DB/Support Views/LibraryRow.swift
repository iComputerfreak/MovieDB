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
                Image(uiImage: mediaObject.thumbnail!)
            }
            VStack {
                Text(mediaObject.tmdbData?.title ?? "Loading...")
                Text(mediaObject.type.rawValue)
            }
        }
    }
}

#if DEBUG
struct LibraryRow_Previews : PreviewProvider {
    static var previews: some View {
        LibraryRow(mediaObject: Media(id: 0, tmdbData: nil, justWatchData: nil, type: .movie))
    }
}
#endif
