//
//  SearchResultRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 29.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import os.log
import SwiftUI

struct SearchResultRow: View {
    /// The search result to display
    @StateObject var result: TMDBSearchResult
    
    var body: some View {
        HStack {
            Image(uiImage: result.thumbnail, defaultImage: JFLiterals.posterPlaceholderName)
                .thumbnail()
            VStack(alignment: .leading) {
                Text(verbatim: "\(result.title)")
                    .bold()
                HStack {
                    if result.isAdultMovie ?? false {
                        Image(systemName: "a.square")
                    }
                    switch result.mediaType {
                    case .movie:
                        Text(Strings.movie)
                            .italic()
                    case .show:
                        Text(Strings.show)
                            .italic()
                    }
                    if let date = self.yearFromMediaResult(result) {
                        Text(verbatim: "(\(date.formatted(.dateTime.year())))")
                    }
                    // Make sure the content is left-aligned
                    Spacer()
                }
                // Make sure the SearchResultView stretches on the whole width, so you can tap it anywhere
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear(perform: result.loadThumbnail)
    }
    
    func yearFromMediaResult(_ result: TMDBSearchResult) -> Date? {
        if result.mediaType == .movie {
            if let date = (result as? TMDBMovieSearchResult)?.releaseDate {
                return date
            }
        } else {
            if let date = (result as? TMDBShowSearchResult)?.firstAirDate {
                return date
            }
        }
        
        return nil
    }
}

struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                List {
                    ForEach(0..<5, id: \.self) { _ in
                        SearchResultRow(result: TMDBMovieSearchResult(
                            id: 0,
                            title: "The Matrix",
                            mediaType: .movie,
                            imagePath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
                            overview: "",
                            originalTitle: "",
                            originalLanguage: "",
                            popularity: 0.0,
                            voteAverage: 0.0,
                            voteCount: 0,
                            isAdult: true,
                            releaseDate: Utils.tmdbUTCDateFormatter.date(from: "2020-04-20")
                        ))
                        .background(Color.red)
                    }
                }
                .navigationTitle(Text(verbatim: "Search Results"))
            }
            
            SearchResultRow(result: TMDBMovieSearchResult(
                id: 0,
                title: "The Matrix",
                mediaType: .movie,
                imagePath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
                overview: "",
                originalTitle: "",
                originalLanguage: "",
                popularity: 0.0,
                voteAverage: 0.0,
                voteCount: 0,
                isAdult: true,
                releaseDate: Utils.tmdbUTCDateFormatter.date(from: "2020-04-20")
            ))
            .background(Color.red)
            .previewLayout(.fixed(width: 300, height: 100))
        }
    }
}
