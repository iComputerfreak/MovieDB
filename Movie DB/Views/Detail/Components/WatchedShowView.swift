//
//  WatchedShowView.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct WatchedShowView: View {
    @Binding var watched: ShowWatchState?
    let maxSeason: Int?
    @Environment(\.isEditing) private var isEditing
    
    private var episodeString: String {
        guard let watched else {
            return Strings.Detail.watchedShowLabelUnknown
        }
        switch watched {
        case .notWatched:
            return Strings.Detail.watchedShowLabelNo
        case let .season(s):
            assert(s > 0)
            return Strings.Detail.watchedShowLabelSeason(s)
        case let .episode(season: s, episode: e):
            assert(e > 0)
            return Strings.Detail.watchedShowLabelSeasonEpisode(s, e)
        }
    }
    
    var body: some View {
        if isEditing {
            NavigationLink {
                EditView(watched: $watched, maxSeason: maxSeason)
            } label: {
                Text(episodeString)
                    .headline(Strings.Detail.watchedHeadline)
            }
        } else {
            Text(episodeString)
                .headline(Strings.Detail.watchedHeadline)
        }
    }
    
    struct EditView: View {
        @Binding var watched: ShowWatchState?
        let maxSeason: Int?
        
        @State private var season: Int
        @State private var episode: Int
        @State private var unknown: Bool
        
        init(watched: Binding<ShowWatchState?>, maxSeason: Int? = nil) {
            _watched = watched
            _season = State(wrappedValue: watched.wrappedValue?.season ?? 0)
            _episode = State(wrappedValue: watched.wrappedValue?.episode ?? 0)
            _unknown = State(wrappedValue: watched.wrappedValue == nil)
            self.maxSeason = maxSeason
        }
        
        var seasonIsValid: Bool {
            guard let maxSeason else {
                return true
            }
            return season <= maxSeason
        }
        
        var warningFooter: Text {
            if seasonIsValid {
                return Text("")
            } else {
                let image = Image(systemName: "exclamationmark.triangle.fill")
                return Text("detail.showWatchState.seasonWarning \(image) \(maxSeason ?? 0)")
            }
        }
        
        var body: some View {
            Form {
                Section(
                    header: Text(Strings.Detail.watchedShowEditingHeader),
                    footer: warningFooter
                ) {
                    Toggle(Strings.Detail.watchedShowEditingLabelUnknown, isOn: $unknown)
                    // Seasons
                    Stepper(value: $season, in: 0...1000) {
                        if self.season > 0 {
                            Text(Strings.Detail.watchedShowLabelSeason(self.season))
                                .foregroundColor(seasonIsValid ? .primary : .yellow)
                        } else {
                            Text(Strings.Detail.watchedShowEditingLabelNotWatched)
                        }
                    }
                    .disabled(unknown)
                    // Episodes
                    if season > 0 {
                        Stepper(value: $episode, in: 0...1000) {
                            if self.episode > 0 {
                                Text(Strings.Detail.watchedShowEditingLabelEpisode(self.episode))
                            } else {
                                Text(Strings.Detail.watchedShowEditingLabelAllEpisodes)
                            }
                        }
                        .disabled(unknown)
                    }
                }
                .onChange(of: self.season) { newSeason in
                    // season < 0 means "unknown"
                    if newSeason < 0 {
                        self.watched = nil
                    } else if newSeason == 0 {
                        // season == 0 means "not watched"
                        self.watched = .notWatched
                    } else {
                        // season > 0 means either .season or .episode
                        
                        // episode > 0 means .episode
                        if episode > 0 {
                            self.watched = .episode(season: newSeason, episode: episode)
                        } else {
                            // episode <= 0 means .season
                            self.watched = .season(newSeason)
                        }
                    }
                }
                .onChange(of: self.episode) { newEpisode in
                    // episode <= 0 means .season
                    if newEpisode <= 0 {
                        self.watched = .season(season)
                    } else {
                        // episode > 0 means .episode
                        self.watched = .episode(season: season, episode: newEpisode)
                    }
                }
                .onChange(of: unknown) { newValue in
                    // If the new state is "unknown"
                    if newValue {
                        self.watched = nil
                    } else {
                        // If the new state if known
                        self.watched = .init(season: season, episode: episode)
                    }
                }
            }
        }
    }
}

struct WatchedShowView_Previews: PreviewProvider {
    static var previews: some View {
        WatchedShowView(
            watched: .constant(.episode(season: 2, episode: 5)),
            maxSeason: 1
        )
        WatchedShowView.EditView(watched: .constant(.episode(season: 2, episode: 5)), maxSeason: 1)
            .previewDisplayName("Edit View")
    }
}
