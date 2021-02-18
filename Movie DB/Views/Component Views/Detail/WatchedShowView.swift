//
//  WatchedShowView.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct WatchedShowView: View {
    
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.editMode) private var editMode
    @State private var isEditing: Bool = false
    
    private var watched: EpisodeNumber? {
        guard let show = mediaObject as? Show else {
            assertionFailure("WatchedShowView must be supplied an EnvironmentObject of type Show.")
            return nil
        }
        return show.lastWatched
    }
    
    private var episodeString: String {
        guard let watched = watched else {
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
                NavigationLink(destination: EditView(show: (mediaObject as! Show)), isActive: $isEditing) {
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
        
        var show: Show
        
        @State private var season: Int
        private var seasonWrapper: Binding<Int> {
            Binding<Int>(get: { self.season }, set: { season in
                self.season = season
                if season == 0 {
                    // Delete both (episode and season)
                    self.show.lastWatched = nil
                } else {
                    self.show.lastSeasonWatched = season
                }
            })
        }
        
        @State private var episode: Int
        private var episodeWrapper: Binding<Int> {
            Binding<Int>(get: { self.episode }, set: { episode in
                self.episode = episode
                self.show.lastEpisodeWatched = (episode == 0 ? nil : episode)
            })
        }
        
        init(show: Show) {
            self.show = show
            self._season = State(wrappedValue: show.lastSeasonWatched ?? 0)
            self._episode = State(wrappedValue: show.lastEpisodeWatched ?? 0)
        }
        
        var body: some View {
            Form {
                Section(header: Text("Up to which Episode did you watch?")) {
                    // TODO: Clamp to the actual amount of seasons/episodes
                    Stepper(value: seasonWrapper, in: 0...100) {
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
        WatchedShowView()
    }
}
