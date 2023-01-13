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
    @Environment(\.isEditing) private var isEditing
    
    private var episodeString: String {
        guard let watched else {
            return Strings.Detail.watchedShowLabelUnknown
        }
        switch watched {
        case .notWatched:
            return Strings.Detail.watchedShowLabelNo
        case let .season(s):
//            assert(s > 0)
            return Strings.Detail.watchedShowLabelSeason(s)
        case let .episode(season: s, episode: e):
//            assert(e > 0)
            return Strings.Detail.watchedShowLabelSeasonEpisode(s, e)
        }
    }
    
    var body: some View {
        if isEditing {
            NavigationLink {
                EditView(watched: $watched)
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
        
        @State private var season: Int
        private var seasonWrapper: Binding<Int> {
            Binding<Int>(get: { self.season }, set: { season in
                self.season = season
                // Update the watched binding
                if season == 0 {
                    // Set to not watched
                    self.watched = .notWatched
                } else {
                    // Update the season
                    if let episode = self.watched?.episode, episode > 0 {
                        self.watched = .episode(season: season, episode: episode)
                    } else {
                        self.watched = .season(season)
                    }
                }
            })
        }
        
        @State private var episode: Int
        private var episodeWrapper: Binding<Int> {
            Binding<Int>(get: { self.episode }, set: { episode in
                self.episode = episode
                if let season = self.watched?.season {
                    // Update the binding
                    self.watched = episode == 0 ? .season(season) : .episode(season: season, episode: episode)
                }
            })
        }
        
        @State private var unknown: Bool
        private var unknownWrapper: Binding<Bool> {
            .init {
                self.unknown
            } set: { newValue in
                self.unknown = newValue
                // If we switched to "known"
                if newValue == false {
                    // Initialize, if not already
                    if self.watched == nil {
                        // Use the values still present in the UI
                        self.watched = .init(season: self.season, episode: self.episode)
                    }
                    // If we switched to "unknown"
                } else {
                    // Deinitialize, but keep the UI values
                    self.watched = nil
                }
            }
        }
        
        init(watched: Binding<ShowWatchState?>) {
            _watched = watched
            _season = State(wrappedValue: watched.wrappedValue?.season ?? 0)
            _episode = State(wrappedValue: watched.wrappedValue?.episode ?? 0)
            _unknown = State(wrappedValue: watched.wrappedValue == nil)
        }
        
        var body: some View {
            Form {
                Section(
                    header: Text(Strings.Detail.watchedShowEditingHeader)
                ) {
                    Toggle(Strings.Detail.watchedShowEditingLabelUnknown, isOn: unknownWrapper)
                    // FUTURE: Clamp to the actual amount of seasons/episodes?
                    // May not be a good idea if the TMDB data is outdated
                    Stepper(value: seasonWrapper, in: 0...1000) {
                        if self.season > 0 {
                            Text(Strings.Detail.watchedShowLabelSeason(self.season))
                        } else {
                            Text(Strings.Detail.watchedShowEditingLabelNotWatched)
                        }
                    }
                    .disabled(unknown)
                    if season > 0 {
                        Stepper(value: episodeWrapper, in: 0...1000) {
                            if self.episode > 0 {
                                Text(Strings.Detail.watchedShowEditingLabelEpisode(self.episode))
                            } else {
                                Text(Strings.Detail.watchedShowEditingLabelAllEpisodes)
                            }
                        }
                        .disabled(unknown)
                    }
                }
            }
        }
    }
}

struct WatchedShowView_Previews: PreviewProvider {
    static var previews: some View {
        WatchedShowView(
            watched: .constant(.episode(season: 2, episode: 5))
        )
        WatchedShowView.EditView(watched: .constant(.episode(season: 2, episode: 5)))
            .previewDisplayName("Edit View")
    }
}
