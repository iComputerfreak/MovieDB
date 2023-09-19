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
    @EnvironmentObject private var mediaObject: Media
    
    var body: some View {
        BaseLibraryRow {
            WatchStateLabel()
        }
    }
}

#Preview {
    func show(for watchState: ShowWatchState) -> Show {
        let show = PlaceholderData.preview.createStaticShow()
        show.watched = watchState
        return show
    }

    func movie(for watchState: MovieWatchState) -> Movie {
        let movie = PlaceholderData.preview.createStaticMovie()
        movie.watched = watchState
        return movie
    }
    
    return NavigationStack {
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
