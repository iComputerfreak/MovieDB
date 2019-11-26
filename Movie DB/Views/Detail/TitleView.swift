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
        Group {
        if thumbnail == nil {
            self.titleView
        } else {
            NavigationLink(destination:
                Image(uiImage: thumbnail!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            ) {
                self.titleView
            }
        }
        }
    }
    
    private var titleView: some View {
        HStack(alignment: VerticalAlignment.center) {
            if (thumbnail != nil) {
                // Thumbnail image
                Image(uiImage: thumbnail!)
                    .poster()
                    .padding([.vertical, .trailing])
            } else {
                // Placeholder image
                JFLiterals.thumbnailPlaceholder
                    .poster()
                    .padding([.vertical, .trailing])
            }
            
            // Title and year
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .lineLimit(3)
                    .padding([.bottom], 5.0)
                if year != nil {
                    Text(String(year!))
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
                TitleView(title: PlaceholderData.movie.tmdbData!.title, year: PlaceholderData.movie.year!, thumbnail: nil)
            }
            Section {
                Text("Other stuff")
            }
        }
    }
}
