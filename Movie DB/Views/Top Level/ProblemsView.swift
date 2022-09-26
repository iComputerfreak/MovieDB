//
//  ProblemsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 21.06.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import CoreData
import SwiftUI

struct ProblemsView: View {
    @FetchRequest(
        entity: Media.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Media.creationDate, ascending: false),
        ],
        // Filter out all media objects that don't have missing information
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                // We don't include
                NSPredicate(
                    format: "type = %@ AND watchedState != %@",
                    MediaType.movie.rawValue,
                    MovieWatchState.notWatched.rawValue
                ),
                // We include all shows since the default value for lastSeasonWatched is already "No"
                NSPredicate(
                    format: "type = %@",
                    MediaType.show.rawValue
                ),
            ]),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Personal Rating missing
                NSPredicate(format: "personalRating = nil"),
                // WatchAgain missing
                NSPredicate(format: "watchAgain = nil"),
                // Tags missing
                NSPredicate(format: "tags.@count = 0"),
                // Watched missing (Movie)
                NSPredicate(format: "type = %@ AND watchedState = nil", MediaType.movie.rawValue),
                // LastWatched missing (Show)
                NSPredicate(
                    format: "type = %@ AND lastEpisodeWatched = nil AND lastSeasonWatched = nil",
                    MediaType.show.rawValue
                ),
            ]),
        ]),
        animation: .default
    ) private var missingInfoMedia: FetchedResults<Media>
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var presentedMedia = PresentedMedia()
    
    var body: some View {
        NavigationView {
            if missingInfoMedia.isEmpty {
                Text(Strings.Problems.noProblemsText)
                    .navigationTitle(Strings.Problems.navBarTitle)
            } else {
                List {
                    ForEach(missingInfoMedia) { mediaObject in
                        Button {
                            self.presentedMedia.media = mediaObject
                        } label: {
                            HStack {
                                ProblemsLibraryRow()
                                    .environmentObject(mediaObject)
                                Spacer()
                                NavigationLinkChevron()
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    .navigationTitle(Strings.Problems.navBarTitle)
                }
                .listStyle(.grouped)
            }
        }
    }
}

struct ProblemsView_Previews: PreviewProvider {
    static var previews: some View {
        ProblemsView()
    }
}

struct PresentedMedia {
    var media: Media?
    var isPresenting: Bool {
        get { media != nil }
        set { media = newValue ? media : nil }
    }
}
