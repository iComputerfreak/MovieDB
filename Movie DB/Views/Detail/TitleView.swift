//
//  DetailThumbnailView.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct TitleView: View {
    @ObservedObject var media: Media
    
    var body: some View {
        if media.thumbnail == nil {
            self.titleView
        } else {
            NavigationLink {
                PosterView(imagePath: media.imagePath)
            } label: {
                self.titleView
            }
        }
    }
    
    private var titleView: some View {
        HStack(alignment: VerticalAlignment.center) {
            Image(uiImage: media.thumbnail, defaultImage: JFLiterals.posterPlaceholderName)
                .thumbnail(multiplier: JFLiterals.detailThumbnailMultiplier)
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

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                TitleView(media: PlaceholderData.movie)
            }
        }
    }
}
