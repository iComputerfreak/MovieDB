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
    enum SubtitleContent: String, Codable, Hashable {
        case problems
        case watchState
        case lastModified
        case personalRating
        case watchDate
        case flatrateWatchProviders
        case nothing
        // TODO: Add watch providers option
        // TODO: Add watch providers filter option
    }

    @EnvironmentObject private var mediaObject: Media
    @ObservedObject private var config: JFConfig = .shared

    let subtitleContent: SubtitleContent?

    init(subtitleContent: SubtitleContent? = nil) {
        self.subtitleContent = subtitleContent
    }

    private var modificationDateDescription: String {
        if let date = mediaObject.modificationDate {
            return date.formatted(date: .numeric, time: .shortened)
        } else {
            return Strings.Generic.never
        }
    }

    private var watchDateDescription: String {
        if let date = mediaObject.watchDate {
            return date.formatted(date: .numeric, time: .omitted)
        } else {
            return Strings.Generic.unknown
        }
    }

    private var problems: [String] {
        mediaObject.missingInformation()
            .map(\.localized)
            .sorted()
    }

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
            switch subtitleContent ?? config.defaultSubtitleContent {
            case .watchState:
                WatchStateLabel()

            case .problems:
                ProblemsLabel(problems: problems)

            case .lastModified:
                Text(Strings.Library.RowSubtitle.lastModified(modificationDateDescription))
                    .font(.subheadline)

            case .personalRating:
                StarRatingView(rating: mediaObject.personalRating)

            case .watchDate:
                Text(Strings.Library.RowSubtitle.watchDate(watchDateDescription))
                    .font(.subheadline)

            case .flatrateWatchProviders:
                FlatrateWatchProvidersLabel(watchProviders: mediaObject.watchProviders)

            case .nothing:
                EmptyView()
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
