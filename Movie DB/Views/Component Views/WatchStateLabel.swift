//
//  WatchStateLabel.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct WatchStateLabel: View {
    // TODO: This should only require an abstracted form of WatchState
    @EnvironmentObject private var mediaObject: Media
    
    var body: some View {
        Group {
            if let movie = mediaObject as? Movie, movie.watched != nil {
                switch movie.watched! {
                case .watched:
                    self.watchedLabel(Strings.Lists.watchlistRowLabelWatchlistStateWatched)
                case .partially:
                    self.partiallyWatchedLabel(
                        Strings.Lists.watchlistRowLabelWatchlistStatePartiallyWatched
                    )
                case .notWatched:
                    self.notWatchedLabel(Strings.Lists.watchlistRowLabelWatchlistStateNotWatched)
                }
            } else if let show = mediaObject as? Show, show.watched != nil {
                switch show.watched! {
                case let .season(s):
                    self.watchedLabel(Strings.Lists.watchlistRowLabelWatchlistStateSeason(season: s))
                case let .episode(season: s, episode: e):
                    self.partiallyWatchedLabel(Strings.Lists.watchlistRowLabelWatchlistStateSeasonEpisode(
                        season: s,
                        episode: e
                    ))
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

struct WatchStateLabel_Previews: PreviewProvider {
    static var previews: some View {
        List {
            WatchStateLabel()
                .environmentObject(PlaceholderData.movie as Media)
            WatchStateLabel()
                .environmentObject({ () -> Media in
                    let show = PlaceholderData.show
                    show.watched = .episode(season: 1, episode: 3)
                    return show
                }())
            WatchStateLabel()
                .environmentObject({ () -> Media in
                    let movie = PlaceholderData.problemMovie
                    movie.watched = .partially
                    return movie
                }())
            WatchStateLabel()
                .environmentObject({ () -> Media in
                    let show = PlaceholderData.problemShow
                    show.watched = .notWatched
                    return show
                }())
        }
    }
}
