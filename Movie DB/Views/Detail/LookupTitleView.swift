//
//  LookupTitleView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI
import JFSwiftUI

// Does not use the media thumbnail, but instead load the thumbnail manually
struct LookupTitleView: View {
    let media: Media
    
    var url: URL? {
        if let imagePath = media.imagePath {
            return Utils.getTMDBImageURL(path: imagePath, size: JFLiterals.thumbnailTMDBSize)
        }
        return nil
    }
    
    var body: some View {
        Group {
            if url == nil {
                self.titleView
            } else {
                NavigationLink(destination: PosterView(imagePath: media.imagePath)) {
                    self.titleView
                }
            }
        }
    }
    
    var titleView: some View {
        HStack(alignment: VerticalAlignment.center) {
            AsyncImage(url: url) { image in
                image
                    .thumbnail(multiplier: JFLiterals.detailThumbnailMultiplier)
            } loading: {
                ProgressView()
            } fallback: {
                Image(JFLiterals.posterPlaceholderName)
                    .thumbnail(multiplier: JFLiterals.detailThumbnailMultiplier)
            }
            .padding([.vertical, .trailing])
            // Title and year
            VStack(alignment: .leading) {
                Text(media.title)
                    .font(.headline)
                    .lineLimit(3)
                    .padding([.bottom], 5.0)
                if media.year != nil {
                    Text(media.year!.description)
                        .padding(4.0)
                        .background(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 2))
                }
            }
        }
    }
}

struct LookupTitleView_Previews: PreviewProvider {
    static var previews: some View {
        LookupTitleView(media: PlaceholderData.movie)
    }
}
