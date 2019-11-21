//
//  MediaDetail.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct MediaDetail : View {
    
    @EnvironmentObject var mediaObject: Media
    
    var body: some View {
        // Group is needed so swift can infer the return type
        Group {
            if (mediaObject.tmdbData == nil) {
                Text("Error loading information!")
            }
            
            // Unwrap the optional data
            mediaObject.tmdbData.map { (data: TMDBData) in
                List {
                    // Thumbnail and basic infos
                    TitleView(title: data.title, year: mediaObject.year, thumbnail: mediaObject.thumbnail)
                    
                    Section(header: Text("Basic Information")) {
                        BasicTextView("ID", text: String(format: "%04d", mediaObject.id))
                        if !data.genres.isEmpty {
                            BasicTextView("Genres", text: data.genres.map({ $0.name }).joined(separator: ", "))
                        }
                        BasicTextView("Original Title", text: data.originalTitle)
                        data.overview.map {
                            LongTextView("Description", text: $0)
                        }
                        BasicTextView("Status", text: data.status)
                        BasicTextView("Original Language", text: JFUtils.languageString(data.originalLanguage))
                    }
                    
                    Section(header: Text("Extended Information")) {
                        // FIXME: Not always correct
                        LinkView(headline: "TMDB ID", text: String(data.id), link: "https://www.themoviedb.org/movie/\(data.id)")
                        data.imdbID.map {
                            LinkView(headline: "IMDB ID", text: $0, link: "https://www.imdb.com/title/\($0)")
                        }
                        if (data.homepageURL != nil && !data.homepageURL!.isEmpty) {
                            LinkView(headline: "Homepage", text: data.homepageURL!, link: data.homepageURL!)
                        }
                        if !data.productionCompanies.isEmpty {
                            BasicTextView("Production Companies", text: String(data.productionCompanies.map({ $0.name }).joined(separator: ", ")))
                        }
                        // TMDB Data
                        BasicTextView("Popularity", text: String(data.popularity))
                        BasicTextView("Scoring", text: "\(String(format: "%.1f", data.voteAverage))/10.0 points from \(data.voteCount) votes")
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
        .navigationBarTitle(Text(mediaObject.tmdbData?.title ?? ""), displayMode: .inline)
    }
}

#if DEBUG
struct MediaDetail_Previews : PreviewProvider {
    static var previews: some View {
        MediaDetail()
            .environmentObject(PlaceholderData.movie)
    }
}
#endif
