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
                        
                        // FIXME: Localize
                        Group {
                            if let movie = mediaObject as? Movie, movie.watched != nil {
                                switch movie.watched! {
                                case .watched:
                                    Text("\(Image(systemName: "checkmark.circle.fill")) Watched")
                                        .foregroundColor(.green)
                                case .partially:
                                    Text("\(Image(systemName: "circle.lefthalf.filled")) Partially Watched")
                                        .foregroundColor(.yellow)
                                case .notWatched:
                                    Text("\(Image(systemName: "circle")) Not Watched")
                                        .foregroundColor(.red)
                                }
                            } else if let show = mediaObject as? Show, show.watched != nil {
                                switch show.watched! {
                                case let .season(s):
                                    Text("\(Image(systemName: "checkmark.circle.fill")) Season \(s)")
                                        .foregroundColor(.green)
                                case let .episode(season: s, episode: e):
                                    Text("\(Image(systemName: "circle.lefthalf.fill")) Season \(s), Episode \(e)")
                                        .foregroundColor(.yellow)
                                case .notWatched:
                                    Text("\(Image(systemName: "circle")) Not Watched")
                                        .foregroundColor(.red)
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
}

struct WatchlistRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
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
            .navigationTitle(Text(verbatim: "Library"))
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
