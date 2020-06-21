//
//  ProblemsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 21.06.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ProblemsView: View {
    
    private let missingInfoFilter: (Media) -> Bool = { (media) -> Bool in
        // If the media is missing any of the user data elements
        if media.personalRating == .noRating ||
            media.watchAgain == nil ||
            media.tags.isEmpty {
            return true
        }
        // Movie exclusive
        if media.type == .movie, let movie = media as? Movie {
            if movie.watched == nil {
                return true
            }
        }
        // Show exclusive
        if media.type == .show, let show = media as? Show {
            if show.lastEpisodeWatched == nil {
                return true
            }
        }
        return false
    }
    private var missingInfo: [Media] {
        return self.library.mediaList.filter(self.missingInfoFilter)
    }
    
    @ObservedObject private var library = MediaLibrary.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Missing Information")) {
                    ForEach(self.missingInfo) { mediaObject in
                        NavigationLink(destination:
                            MediaDetail()
                                .environmentObject(mediaObject)
                        ) {
                            LibraryRow()
                                .environmentObject(mediaObject)
                        }
                    }
                    .onDelete { indexSet in
                        for offset in indexSet {
                            let id = self.missingInfo[offset].id
                            self.library.remove(id: id)
                            DispatchQueue.global().async {
                                self.library.save()
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Problems")
        }
    }
}

struct ProblemsView_Previews: PreviewProvider {
    static var previews: some View {
        ProblemsView()
    }
}
