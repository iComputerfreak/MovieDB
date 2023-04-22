//
//  DebugView.swift
//  Movie DB
//
//  Created by Jonas Frey on 18.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CloudKit
import CoreData
import SwiftUI

struct DebugView: View {
    let context = PersistenceController.viewContext
    
    @StateObject private var mediaCount = EntityCount(name: "Media")
    @StateObject private var genreCount = EntityCount(name: "Genre")
    @StateObject private var tagCount = EntityCount(name: "Tag")
    @StateObject private var pcCount = EntityCount(name: "ProductionCompany")
    @StateObject private var videoCount = EntityCount(name: "Video")
    @StateObject private var seasonCount = EntityCount(name: "Season")
    
    var allCounts: [EntityCount] {
        [
            mediaCount,
            genreCount,
            tagCount,
            pcCount,
            videoCount,
            seasonCount,
        ]
    }
    
    // swiftlint:disable:next large_tuple
    var duplicates: (id: Int, tmdbID: Int, objectID: Int) {
        guard let allMedias = try? context.fetch(Media.fetchRequest()) else {
            return (-1, -1, -1)
        }
        let id = allMedias.removingDuplicates(key: \.id).count
        let tmdbID = allMedias.removingDuplicates(key: \.tmdbID).count
        let objectID = allMedias.removingDuplicates(key: \.objectID).count
        let c = allMedias.count
        return (c - id, c - tmdbID, c - objectID)
    }
    
    var body: some View {
        List {
            Section("Core Data") {
                ForEach(allCounts, id: \.entityName) { count in
                    VStack(alignment: .leading) {
                        Text(count.entityName)
                        Group {
                            Text("Local: \(count.localCountDescription)")
                            Text("Unique Local: \(count.uniqueLocalCountDescription)")
                            Text("Remote: \(count.remoteCountDescription)")
                        }
                        .font(.caption)
                        .padding(.leading)
                    }
                }
            }
            Section("Duplicates") {
                let (duplicateID, duplicateTmdbID, duplicateObjectID) = duplicates
                Text("There are \(duplicateID) media object with identical IDs.")
                Text("There are \(duplicateTmdbID) media object with identical TMDB IDs.")
                Text("There are \(duplicateObjectID) media object with identical Object IDs.")
            }
            BackgroundFetchDebugSection()
        }
        .refreshable {
            self.update()
        }
        .navigationTitle("Debug")
    }
    
    func update() {
        // Invalidate all currently displayed results
        for count in allCounts {
            count.invalidate()
        }
        
        // Re-count them
        self.mediaCount.update(\Media.id)
        self.genreCount.update(\Genre.id)
        self.tagCount.update(\Tag.id)
        self.pcCount.update(\ProductionCompany.id)
        self.videoCount.update(\Video.key)
        self.seasonCount.update(\Season.id)
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
