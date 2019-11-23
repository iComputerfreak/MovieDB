//
//  SearchResultView.swift
//  Movie DB
//
//  Created by Jonas Frey on 29.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct SearchResultView : View {
    
    /// The search result to display
    @State var result: TMDBSearchResult
    
    /// The image used as a thumbnail for the search results
    @State private var image: UIImage?
    
    /// Returns either the release year of the movie or the year of the first air date of the show
    var year: Int? {
        let year = (result as? TMDBMovieSearchResult)?.releaseDate ?? (result as? TMDBShowSearchResult)?.firstAirDate
        guard let _ = year else {
            return nil
        }
        return JFUtils.yearOfDate(year!)
    }
    
    // View did appear
    func didAppear() {
        guard let imagePath = result.imagePath else {
            print("\(result.title) has no thumbnail")
            return
        }
        let urlString = JFUtils.getTMDBImageURL(path: imagePath)
        JFUtils.getRequest(urlString, parameters: [:]) { (data) in
            guard let data = data else {
                print("Error getting search result image")
                return
            }
            self.image = UIImage(data: data)
        }
    }
    
    var body: some View {
        HStack {
            if (image != nil) {
                // Thumbnail image
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: JFLiterals.thumbnailSize.width, height: JFLiterals.thumbnailSize.height, alignment: .center)
            } else {
                // Placeholder image
                Image(systemName: (result.mediaType == .movie ? "film" : "tv"))
                    .resizable()
                    .aspectRatio((result.mediaType == .movie ? 0.9 : 1.0), contentMode: .fit)
                    .padding(5)
                    .frame(width: JFLiterals.thumbnailSize.width, height: JFLiterals.thumbnailSize.height, alignment: .center)
            }
            VStack(alignment: .leading) {
                Text("\(result.title)")
                    .bold()
                HStack {
                    if (result.isAdultMovie ?? false) {
                        Image(systemName: "a.square")
                    }
                    Text(result.mediaType == .movie ? "Movie" : "Series")
                        .italic()
                    Text(year != nil ? "(\(String(describing: year!)))" : "")
                }
            }
        }
        .onAppear(perform: self.didAppear)
    }
}

#if DEBUG
struct SearchResultView_Previews : PreviewProvider {
    static var previews: some View {
        Text("Not implemeted")
        //SearchResultView()
    }
}
#endif
