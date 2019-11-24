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
                    // MARK: - Thumbnail
                    TitleView(title: data.title, year: mediaObject.year, thumbnail: mediaObject.thumbnail)
                    // MARK: - User Data
                    Section(header: Text("User Data")) {
                        // Rating
                        RatingView(rating: $mediaObject.personalRating)
                            .headline("Personal Rating")
                        // Watched field
                        if mediaObject.type == .movie {
                            SimpleValueView<Bool>.createYesNo(value: Binding<Bool?>(get: { (self.mediaObject as! Movie).watched }, set: { (self.mediaObject as! Movie).watched = $0 }))
                                .headline("Watched?")
                        } else {
                            (mediaObject as? Show).map { (show: Show) in
                                // Has watched show field
                                Text("")
                            }
                        }
                        // Watch again field
                        SimpleValueView<Any>.createYesNo(value: $mediaObject.watchAgain)
                            .headline("Watch again?")
                        // Taglist
                        // Notes
                    }
                    // MARK: - Basic Information
                    Section(header: Text("Basic Information")) {
                        Text(String(format: "%04d", mediaObject.id))
                            .headline("ID")
                        if !data.genres.isEmpty {
                            Text(data.genres.map({ $0.name }).joined(separator: ", "))
                            .headline("Genres")
                        }
                        Text(data.originalTitle)
                            .headline("Original Title")
                        data.overview.map {
                            LongTextView("Description", text: $0)
                        }
                        Text(data.status)
                            .headline("Status")
                        Text(JFUtils.languageString(data.originalLanguage))
                        .headline("Original Language")
                    }
                    // MARK: - Extended Information
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
                            Text(String(data.productionCompanies.map({ $0.name }).joined(separator: ", ")))
                            .headline("Production Companies")
                        }
                        // TMDB Data
                        Text(String(data.popularity))
                            .headline("Popularity")
                        Text("\(String(format: "%.1f", data.voteAverage))/10.0 points from \(data.voteCount) votes")
                        .headline("Scoring")
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
