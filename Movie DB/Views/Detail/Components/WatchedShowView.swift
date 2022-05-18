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
    @Binding var lastWatched: EpisodeNumber?
    @Environment(\.editMode) private var editMode
    @State private var isEditing = false
    
    private var episodeString: String {
        guard let watched = lastWatched else {
            return String(
                localized: "detail.userData.watchedShow.label.no",
                comment: "The label in the detail view describing that the user has not watched the show"
            )
        }
        if watched.episode == nil {
            return String(
                localized: "detail.userData.watchedShow.label.season \(watched.season)",
                // swiftlint:disable:next line_length
                comment: "The label in the detail view describing that the user has watched up to a specific season of the show. The parameter is the season number."
            )
        } else {
            return String(
                localized: "detail.userData.watchedShow.label.seasonAndEpisode \(watched.season) \(watched.episode!)",
                // swiftlint:disable:next line_length
                comment: "The label in the detail view describing that the user has watched up to a specific episode of a season of the show. The first parameter is the season number. The second parameter is the episode number."
            )
        }
    }
    
    var body: some View {
        Group {
            if editMode?.wrappedValue.isEditing ?? false {
                NavigationLink(destination: EditView(lastWatched: $lastWatched), isActive: $isEditing) {
                    Text(episodeString)
                }
                .onTapGesture {
                    self.isEditing = true
                }
            } else {
                Text(episodeString)
            }
        }
    }
    
    struct EditView: View {
        @Binding var lastWatched: EpisodeNumber?
        
        @State private var season: Int
        private var seasonWrapper: Binding<Int> {
            Binding<Int>(get: { self.season }, set: { season in
                self.season = season
                if season == 0 {
                    // Delete both (episode and season)
                    self.lastWatched = nil
                } else {
                    // Update the season (or create, if nil)
                    if self.lastWatched == nil {
                        self.lastWatched = EpisodeNumber(season: season)
                    } else {
                        self.lastWatched!.season = season
                    }
                }
            })
        }
        
        @State private var episode: Int
        private var episodeWrapper: Binding<Int> {
            Binding<Int>(get: { self.episode }, set: { episode in
                self.episode = episode
                self.lastWatched?.episode = (episode == 0 ? nil : episode)
            })
        }
        
        init(lastWatched: Binding<EpisodeNumber?>) {
            self._lastWatched = lastWatched
            self._season = State(wrappedValue: lastWatched.wrappedValue?.season ?? 0)
            self._episode = State(wrappedValue: lastWatched.wrappedValue?.episode ?? 0)
        }
        
        var body: some View {
            Form {
                Section(
                    header: Text(
                        "detail.userData.watchedShow.header",
                        // swiftlint:disable:next line_length
                        comment: "The header in the editing view where the user specifies up to which season/episode they watched."
                    )
                ) {
                    // FUTURE: Clamp to the actual amount of seasons/episodes?
                    // May not be a good idea if the TMDB data is outdated
                    Stepper(value: seasonWrapper, in: 0...1000) {
                        if self.season > 0 {
                            Text(
                                "detail.userData.watchedShow.label.seasonNumber \(self.season)",
                                // swiftlint:disable:next line_length
                                comment: "The label of the picker in the detail view where the user specifies up to which season they watched. Label specifies the season number. The parameter is the season number."
                            )
                        } else {
                            Text(
                                "detail.userData.watchedShow.label.notWatched",
                                // swiftlint:disable:next line_length
                                comment: "The label of the picker in the detail view where the user specifies up to which season they watched. Label specifies that the user did not watch the show."
                            )
                        }
                    }
                    if season > 0 {
                        Stepper(value: episodeWrapper, in: 0...1000) {
                            if self.episode > 0 {
                                Text(
                                    "detail.userData.watchedShow.label.episodeNumber \(self.episode)",
                                    // swiftlint:disable:next line_length
                                    comment: "The label of the picker in the detail view where the user specifies up to which episode they watched. Label specifies the episode number. The parameter is the episode number."
                                )
                            } else {
                                Text(
                                    "detail.userData.watchedShow.label.allEpisodes",
                                    // swiftlint:disable:next line_length
                                    comment: "The label of the picker in the detail view where the user specifies up to which episode they watched. Label specifies that the user watched all episodes of the season."
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

struct WatchedShowView_Previews: PreviewProvider {
    static var previews: some View {
        WatchedShowView(lastWatched: .constant(EpisodeNumber(season: 2, episode: 5)))
    }
}
