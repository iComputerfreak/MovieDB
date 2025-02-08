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
    enum SubtitleContent {
        case problems([String])
        case watchState
    }

    @EnvironmentObject private var mediaObject: Media

    let subtitleContent: SubtitleContent

    var body: some View {
        BaseLibraryRow(
            capsules: [
                .mediaType,
                .releaseYear,
                .parentalRating,
                .isAdultMedia,
                .isFavorite,
                .isOnWatchlist
            ]
        ) {
            switch subtitleContent {
            case .watchState:
                WatchStateLabel()

            case let .problems(problems):
                ProblemsLabel(problems: problems)
            }
        }
    }
}

#if DEBUG
#Preview("Watch State") {
    NavigationStack {
        List {
            ForEach(MovieWatchState.allCases, id: \.rawValue) { watchState in
                LibraryRow(subtitleContent: .watchState)
                    .environmentObject(movie(for: watchState) as Media)
            }
            ForEach([
                .season(3),
                .episode(season: 1, episode: 5),
                ShowWatchState.notWatched,
            ], id: \.rawValue) { watchState in
                LibraryRow(subtitleContent: .watchState)
                    .environmentObject(show(for: watchState) as Media)
            }
        }
        .navigationTitle(Text(verbatim: "Watchlist"))
    }
}

private func show(for watchState: ShowWatchState) -> Show {
    let show = PlaceholderData.preview.createStaticShow()
    show.watched = watchState
    return show
}

private func movie(for watchState: MovieWatchState) -> Movie {
    let movie = PlaceholderData.preview.createStaticMovie()
    movie.watched = watchState
    movie.isFavorite = watchState == .watched || watchState == .notWatched
    movie.isOnWatchlist = watchState == .partially || watchState == .notWatched
    return movie
}
#endif
