//
//  WatchStateLabel.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct WatchStateLabel: View {
    @EnvironmentObject private var mediaObject: Media
    
    var maxSeason: Int? {
        guard let show = mediaObject as? Show else { return nil }
        return show.latestNonEmptySeasonNumber ?? show.numberOfSeasons
    }
    
    func maxEpisode(for season: Int) -> Int? {
        guard let show = mediaObject as? Show else { return nil }
        return show.seasons.first(where: \.seasonNumber, equals: season)?.episodeCount
    }
    
    var body: some View {
        Group {
            if let movie = mediaObject as? Movie, let movieWatched = movie.watched {
                switch movieWatched {
                case .watched:
                    self.watchedLabel(Strings.Lists.watchlistRowLabelWatchlistStateWatched)
                case .partially:
                    self.partiallyWatchedLabel(
                        Strings.Lists.watchlistRowLabelWatchlistStatePartiallyWatched
                    )
                case .notWatched:
                    self.notWatchedLabel(Strings.Lists.watchlistRowLabelWatchlistStateNotWatched)
                }
            } else if let show = mediaObject as? Show, let showWatched = show.watched {
                switch showWatched {
                case let .season(s):
                    if let maxSeason, s < maxSeason {
                        // Show as partially watched, since there are further seasons available
                        self.partiallyWatchedLabel(Strings.Lists.watchlistRowLabelWatchlistStateSeasonOfMax(
                            season: s,
                            maxSeason: maxSeason
                        ))
                    } else {
                        // Show as complete, since there are no more seasons available
                        self.watchedLabel(Strings.Lists.watchlistRowLabelWatchlistStateSeason(season: s))
                    }
                case let .episode(season: s, episode: e):
                    if
                        let maxSeason,
                        let maxEpisode = maxEpisode(for: s),
                        e >= maxEpisode,
                        s >= maxSeason
                    {
                        // Show as complete, since there are no more episodes and seasons available
                        self.watchedLabel(
                            Strings.Lists.watchlistRowLabelWatchlistStateSeasonEpisode(season: s, episode: e)
                        )
                    } else {
                        self.partiallyWatchedLabel(Strings.Lists.watchlistRowLabelWatchlistStateSeasonEpisode(
                            season: s,
                            episode: e
                        ))
                    }
                case .notWatched:
                    self.notWatchedLabel(Strings.Lists.watchlistRowLabelWatchlistStateNotWatched)
                }
            }
        }
        .font(.subheadline)
        .bold()
    }
    
    func watchedLabel(_ text: String) -> WatchedLabel {
        WatchedLabel(
            labelText: text,
            systemImage: "checkmark.circle.fill",
            color: .green
        )
    }
    
    func partiallyWatchedLabel(_ text: String) -> WatchedLabel {
        WatchedLabel(
            labelText: text,
            systemImage: "circle.lefthalf.fill",
            color: .yellow
        )
    }
    
    func notWatchedLabel(_ text: String) -> WatchedLabel {
        WatchedLabel(
            labelText: text,
            systemImage: "circle",
            color: .red
        )
    }
}

#Preview {
    func createMovie(watchState: MovieWatchState?) -> Media {
        create(.movie, watchState: watchState)
    }
    
    func createShow(watchState: ShowWatchState?) -> Media {
        create(.show, watchState: watchState)
    }
    
    func create(_ type: MediaType, watchState: WatchState?) -> Media {
        switch type {
        case .movie:
            let movie = PlaceholderData.preview.createStaticMovie()
            movie.watched = watchState as? MovieWatchState
            return movie
        case .show:
            let show = PlaceholderData.preview.createStaticShow()
            show.watched = watchState as? ShowWatchState
            return show
        }
    }
    
    return List {
        Section(header: Text(verbatim: "Movies")) {
            WatchStateLabel()
                .environmentObject(createMovie(watchState: nil))
            WatchStateLabel()
                .environmentObject(createMovie(watchState: .watched))
            WatchStateLabel()
                .environmentObject(createMovie(watchState: .partially))
            WatchStateLabel()
                .environmentObject(createMovie(watchState: .notWatched))
        }
        Section(header: Text(verbatim: "Shows")) {
            WatchStateLabel()
                .environmentObject(createShow(watchState: nil))
            WatchStateLabel()
                .environmentObject(createShow(watchState: .season(9)))
            WatchStateLabel()
                .environmentObject(createShow(watchState: .season(2)))
            WatchStateLabel()
                .environmentObject(createShow(watchState: .episode(season: 1, episode: 3)))
            WatchStateLabel()
                .environmentObject(createShow(watchState: .notWatched))
        }
    }
}
