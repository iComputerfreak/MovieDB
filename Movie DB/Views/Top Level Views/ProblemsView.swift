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
    
    @ObservedObject private var library = MediaLibrary.shared
    
    @FetchRequest(
        entity: Media.entity(),
        sortDescriptors: [],
        // Filter out all media objects that don't have missing information
        predicate: NSCompoundPredicate(orPredicateWithSubpredicates: [
            // Personal Rating missing
            NSPredicate(format: "personalRating = nil"),
            // WatchAgain missing
            NSPredicate(format: "watchAgain = nil"),
            // Tags missing
            NSPredicate(format: "tags.@count = 0"),
            // Watched missing (Movie)
            NSPredicate(format: "type = %@ AND watched = nil", MediaType.movie.rawValue),
            // LastWatched missing (Show)
            NSPredicate(format: "type = %@ AND lastEpisodeWatched = nil AND lastSeasonWatched = nil", MediaType.show.rawValue)
        ]),
        animation: nil
    ) private var missingInfoMedia: FetchedResults<Media>
    
    
    
    @State private var problems: [Media: Set<Media.MediaInformation>] = [:]
        
    var body: some View {
        NavigationView {
            if missingInfoMedia.isEmpty {
                Text("There are no problems in your library.")
                    .navigationBarTitle("Problems")
            } else {
                List {
                    ForEach(missingInfoMedia) { mediaObject in
                        ProblemsLibraryRow(content: Text("Missing: \(mediaObject.missingInformation().map(\.rawValue).joined(separator: ", "))").italic())
                            .environmentObject(mediaObject)
                    }
                }
                .navigationBarTitle("Problems")
            }
        }
    }
}

struct ProblemsView_Previews: PreviewProvider {
    static var previews: some View {
        ProblemsView()
    }
}
