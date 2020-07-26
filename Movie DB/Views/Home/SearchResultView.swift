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
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(uiImage: image, defaultImage: JFLiterals.posterPlaceholderName)
                .thumbnail()
            VStack(alignment: .leading) {
                Text("\(result.title)")
                    .bold()
                HStack {
                    if (result.isAdultMovie ?? false) {
                        Image(systemName: "a.square")
                    }
                    Text(result.mediaType == .movie ? "Movie" : "Series")
                        .italic()
                    // Make sure the content is left-aligned
                    Spacer()
                }
                // Make sure the SearchResultView stretches on the whole width, so you can tap it anywhere
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear(perform: self.didAppear)
    }
}

#if DEBUG
struct SearchResultView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                List {
                    ForEach(0..<5, id: \.self) { i in
                        SearchResultView(result: TMDBMovieSearchResult(id: 0, title: "The Matrix", mediaType: .movie, imagePath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg", overview: "", originalTitle: "", originalLanguage: "", popularity: 0.0, voteAverage: 0.0, voteCount: 0, isAdult: true, rawReleaseDate: "2020-04-20"))
                            .background(Color.red)
                    }
                }
                .navigationTitle("Search Results")
            }
            
            
            SearchResultView(result: TMDBMovieSearchResult(id: 0, title: "The Matrix", mediaType: .movie, imagePath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg", overview: "", originalTitle: "", originalLanguage: "", popularity: 0.0, voteAverage: 0.0, voteCount: 0, isAdult: true, rawReleaseDate: "2020-04-20"))
                .background(Color.red)
                .previewLayout(.fixed(width: 300, height: 100))
        }
    }
}
#endif
