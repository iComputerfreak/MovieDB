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
    
    private var episodeString: LocalizedStringKey {
        guard let watched = lastWatched else {
            return "No"
        }
        if watched.episode == nil {
            return "Season \(watched.season)"
        } else {
            return "Season \(watched.season), Episode \(watched.episode!)"
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
                Section(header: Text("Up to which Episode did you watch?")) {
                    // FUTURE: Clamp to the actual amount of seasons/episodes?
                    // May not be a good idea if the TMDB data is outdated
                    Stepper(value: seasonWrapper, in: 0...1000) {
                        if self.season > 0 {
                            Text("Season \(self.season)")
                        } else {
                            Text("Not Watched")
                        }
                    }
                    if season > 0 {
                        Stepper(value: episodeWrapper, in: 0...1000) {
                            if self.episode > 0 {
                                Text("Episode \(self.episode)")
                            } else {
                                Text("All Episodes")
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
