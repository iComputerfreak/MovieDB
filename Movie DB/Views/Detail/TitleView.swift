//
//  DetailThumbnailView.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct TitleView: View {
    
    var title: String
    var year: Int?
    var thumbnail: UIImage?
    
    var body: some View {
        if thumbnail == nil {
            return AnyView(self.titleView)
        } else {
            return AnyView(NavigationLink(destination:
                Image(uiImage: thumbnail!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            ) {
                self.titleView
            })
        }
    }
    
    private var titleView: some View {
        HStack(alignment: VerticalAlignment.center) {
            Image(uiImage: thumbnail, defaultSystemImage: "film")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: JFLiterals.thumbnailSize.width * 2, height: JFLiterals.thumbnailSize.height * 2, alignment: .leading)
                .padding()
            
            // Title and year
            VStack(alignment: .leading) {
                Text(title)
                    .padding([.bottom], 5.0)
                    .font(.headline)
                    .lineLimit(2)
                if year != nil {
                    Text(String(year!))
                        .padding(4.0)
                        .border(Color.primary, width: 2) // TODO: Add corner radius 5
                }
            }
            Spacer()
        }
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(title: PlaceholderData.movie.tmdbData!.title, year: PlaceholderData.movie.year!, thumbnail: nil)
    }
}
