//
//  ProblemsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 21.06.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import SwiftUI
import CoreData

struct ProblemsView: View {
    @FetchRequest(
        entity: Media.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Media.creationDate, ascending: false)
        ],
        // Filter out all media objects that don't have missing information
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(
                    format: "type = %@ AND watched = TRUE",
                    MediaType.movie.rawValue
                ),
                NSPredicate(
                    format: "type = %@ AND watched = nil",
                    MediaType.movie.rawValue
                ),
                // We include all shows since the default value for lastSeasonWatched is already "No"
                NSPredicate(
                    format: "type = %@",
                    MediaType.show.rawValue
                )
            ]),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Personal Rating missing
                NSPredicate(format: "personalRating = nil"),
                // WatchAgain missing
                NSPredicate(format: "watchAgain = nil"),
                // Tags missing
                NSPredicate(format: "tags.@count = 0"),
                // Watched missing (Movie)
                NSPredicate(format: "type = %@ AND watched = nil", MediaType.movie.rawValue),
                // LastWatched missing (Show)
                NSPredicate(
                    format: "type = %@ AND lastEpisodeWatched = nil AND lastSeasonWatched = nil",
                    MediaType.show.rawValue
                )
            ])
        ]),
        animation: .default
    ) private var missingInfoMedia: FetchedResults<Media>
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var problems: [Media: Set<Media.MediaInformation>] = [:]
    @State private var presentedMedia = PresentedMedia()
    
    var body: some View {
        NavigationView {
            ZStack {
                // We maintain an invisible list in the background to be able to permanently keep a NavigationLink
                // "visible" that can be triggered programmatically. This way, we can keep the selected media active,
                // even after the below if-else-code evaluates to the true branch and hides the list of medias.
                List {
                    NavigationLink(isActive: $presentedMedia.isPresenting) {
                        if let mediaObject = presentedMedia.media {
                            MediaDetail()
                                .environmentObject(mediaObject)
                        } else {
                            Text("Error")
                        }
                    } label: {
                        EmptyView()
                    }
                    .hidden()
                    .frame(height: 0)
                }
                .disabled(true)
                .opacity(0)
                
                if missingInfoMedia.isEmpty {
                    Text("There are no problems in your library.")
                        .navigationBarTitle("Problems")
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
                        .navigationBarTitle("Problems")
                    }
                    .listStyle(.grouped)
                }
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
