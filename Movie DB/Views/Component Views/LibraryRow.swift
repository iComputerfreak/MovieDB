//
//  LibraryRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.08.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents the label of a list displaying media objects.
/// Presents various data about the media object, e.g. the thumbnail image, title and year
/// Requires the displayed media object as an `EnvironmentObject`.
struct LibraryRow: View {
    @EnvironmentObject var mediaObject: Media
    
    let movieSymbolText = Strings.Library.movieSymbolName
    let seriesSymbolText = Strings.Library.showSymbolName
    
    var body: some View {
        if mediaObject.isFault {
            // This will be displayed while the object is being deleted
            EmptyView()
        } else {
            HStack {
                Image(uiImage: mediaObject.thumbnail, defaultImage: JFLiterals.posterPlaceholderName)
                    .thumbnail()
                VStack(alignment: .leading, spacing: 4) {
                    Text(mediaObject.title)
                        .lineLimit(2)
                        .font(.headline)
                    // Under the title
                    HStack {
                        // MARK: Type
                        switch mediaObject.type {
                        case .movie:
                            CapsuleLabelView(text: movieSymbolText)
                        case .show:
                            CapsuleLabelView(text: seriesSymbolText)
                        }
                        // MARK: FSK Rating
                        if let rating = mediaObject.parentalRating {
                            rating.symbol
                                .font(.caption2)
                        }
                        // MARK: Year
                        if let year = mediaObject.year {
                            CapsuleLabelView(text: year.description)
                        }
                    }
                    .font(.subheadline)
                    
                    WatchStateLabel()
                }
            }
        }
    }
}

struct LibraryRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                ForEach(MovieWatchState.allCases, id: \.rawValue) { watchState in
                    LibraryRow()
                        .environmentObject(movie(for: watchState) as Media)
                }
                ForEach([
                    .season(3),
                    .episode(season: 1, episode: 5),
                    ShowWatchState.notWatched,
                ], id: \.rawValue) { watchState in
                    LibraryRow()
                        .environmentObject(show(for: watchState) as Media)
                }
            }
            .navigationTitle(Text(verbatim: "Watchlist"))
        }
    }
    
    static func show(for watchState: ShowWatchState) -> Show {
        let show = PlaceholderData.createShow()
        show.watched = watchState
        return show
    }
    
    static func movie(for watchState: MovieWatchState) -> Movie {
        let movie = PlaceholderData.createMovie()
        movie.watched = watchState
        return movie
    }
}
