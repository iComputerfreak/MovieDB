//
//  WatchlistRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.08.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct WatchlistRow: View {
    @EnvironmentObject var mediaObject: Media
    
    let movieSymbol = Strings.Library.movieSymbolName
    let seriesSymbol = Strings.Library.showSymbolName
    
    var body: some View {
        if mediaObject.isFault {
            // This will be displayed while the object is being deleted
            EmptyView()
        } else {
            NavigationLink {
                MediaDetail()
                    .environmentObject(mediaObject)
            } label: {
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
                            if mediaObject.type == .movie {
                                Image(systemName: movieSymbol)
                            } else {
                                Image(systemName: seriesSymbol)
                            }
                            // MARK: FSK Rating
                            if let rating = mediaObject.parentalRating {
                                rating.symbol
                                    .font(.caption2)
                            }
                            // MARK: Year
                            if mediaObject.year != nil {
                                Text(mediaObject.year!.description)
                            }
                        }
                        .font(.subheadline)
                        
                        Group {
                            if let movie = mediaObject as? Movie, movie.watched != nil {
                                switch movie.watched! {
                                case .watched:
                                    WatchedLabel(
                                        labelText: Strings.Lists.watchlistRowLabelWatchlistStateWatched,
                                        systemImage: "checkmark.circle.fill",
                                        color: .green
                                    )
                                case .partially:
                                    WatchedLabel(
                                        labelText: Strings.Lists.watchlistRowLabelWatchlistStatePartiallyWatched,
                                        systemImage: "circle.lefthalf.filled",
                                        color: .yellow
                                    )
                                case .notWatched:
                                    WatchedLabel(
                                        labelText: Strings.Lists.watchlistRowLabelWatchlistStateNotWatched,
                                        systemImage: "circle",
                                        color: .red
                                    )
                                }
                            } else if let show = mediaObject as? Show, show.watched != nil {
                                switch show.watched! {
                                case let .season(s):
                                    WatchedLabel(
                                        labelText: Strings.Lists.watchlistRowLabelWatchlistStateSeason(season: s),
                                        systemImage: "checkmark.circle.fill",
                                        color: .green
                                    )
                                case let .episode(season: s, episode: e):
                                    WatchedLabel(
                                        labelText: Strings.Lists.watchlistRowLabelWatchlistStateSeasonEpisode(
                                            season: s,
                                            episode: e
                                        ),
                                        systemImage: "circle.lefthalf.fill",
                                        color: .yellow
                                    )
                                case .notWatched:
                                    WatchedLabel(
                                        labelText: Strings.Lists.watchlistRowLabelWatchlistStateNotWatched,
                                        systemImage: "circle",
                                        color: .red
                                    )
                                }
                            }
                        }
                        .font(.subheadline)
                        .bold()
                    }
                }
            }
        }
    }
    
    struct WatchedLabel: View {
        let labelText: String
        let systemImage: String
        let color: Color
        
        var body: some View {
            (
                Text(Image(systemName: systemImage)) +
                    Text(verbatim: " ") +
                    Text(labelText)
            )
            .foregroundColor(color)
        }
    }
}

struct WatchlistRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                ForEach(MovieWatchState.allCases, id: \.rawValue) { watchState in
                    WatchlistRow()
                        .environmentObject(movie(for: watchState) as Media)
                }
                ForEach([
                    .season(3),
                    .episode(season: 1, episode: 5),
                    ShowWatchState.notWatched,
                ], id: \.rawValue) { watchState in
                    WatchlistRow()
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
