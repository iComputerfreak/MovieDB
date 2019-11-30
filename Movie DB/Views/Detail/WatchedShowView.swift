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
    
    private var watched: Show.EpisodeNumber? {
        guard let show = mediaObject as? Show else {
            assert(false, "WatchedShowView must be supplied an EnvironmentObject of type Show.")
            return nil
        }
        return show.lastEpisodeWatched
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
                    // Delete
                    self.show.lastEpisodeWatched = nil
                } else {
                    // Update
                    if self.show.lastEpisodeWatched == nil {
                        // Create new
                        self.show.lastEpisodeWatched = Show.EpisodeNumber(season: season)
                    } else {
                        // Update
                        self.show.lastEpisodeWatched!.season = season
                    }
                }
            })
        }
        
        @State private var episode: Int
        private var episodeWrapper: Binding<Int> {
            Binding<Int>(get: { self.episode }, set: { episode in
                self.episode = episode
                self.show.lastEpisodeWatched?.episode = (episode == 0 ? nil : episode)
            })
        }
        
        init(show: Show) {
            self.show = show
            self._season = State(wrappedValue: show.lastEpisodeWatched?.season ?? 0)
            self._episode = State(wrappedValue: show.lastEpisodeWatched?.episode ?? 0)
        }
        
        var body: some View {
            Form {
                Section(header: Text("Up to which Episode did you watch?")) {
                    Stepper(value: seasonWrapper) {
                        if self.season > 0 {
                            Text("Season \(self.season)")
                        } else {
                            Text("Not Watched")
                        }
                    }
                    if season > 0 {
                        Stepper(value: episodeWrapper) {
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
