//
//  DetailThumbnailView.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct TitleView: View {
    let title: String
    let year: Int?
    @State var thumbnail: Thumbnail?
    
    var body: some View {
        Group {
            if thumbnail?.image == nil {
                self.titleView
            } else {
                NavigationLink(
                    destination: Image(uiImage: thumbnail?.image, defaultImage: JFLiterals.posterPlaceholderName)
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
            Image(uiImage: thumbnail?.image, defaultImage: JFLiterals.posterPlaceholderName)
                .thumbnail(multiplier: 2.0)
                .padding([.vertical, .trailing])
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
                TitleView(title: PlaceholderData.movie.title, year: PlaceholderData.movie.year!, thumbnail: nil)
            }
            Section {
                Text("Other stuff")
            }
        }
    }
}
