//
//  ProblemsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 21.06.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ProblemsView: View {
    
    // MARK: Missing Info
    // Don't use checkProblems, as this check here is more efficient and has to be executed for every library item
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
    
    // MARK: Duplicates
    // Returns all duplicates grouped by ID
    private var duplicateEntries: [Media] {
        // Group the media objects by their TMDB IDs
        let duplicates = Dictionary(grouping: library.mediaList, by: \.tmdbData?.id)
            // Filter out all IDs with only one media object
            .filter { (key: Int?, value: [Media]) in
                return value.count > 1
            }
        // Only return the media objects
        return duplicates.flatMap(\.value).sorted { (media1, media2) in
            // Sort nil before real IDs
            guard let data1 = media1.tmdbData else {
                return true
            }
            guard let data2 = media2.tmdbData else {
                return false
            }
            return data1.id < data2.id
        }
    }
    
    @ObservedObject private var library = MediaLibrary.shared
    
    // Only has to be executed for the prolematic media objects
    private func checkProblems(_ mediaObject: Media) -> [String] {
        var problems = [String]()
        if mediaObject.personalRating == .noRating {
            problems.append("rating")
        }
        if mediaObject.watchAgain == nil {
            problems.append("watch again")
        }
        if mediaObject.tags.isEmpty {
            problems.append("tags")
        }
        if let movie = mediaObject as? Movie, movie.watched == nil {
            problems.append("watched")
        }
        if let show = mediaObject as? Show, show.lastEpisodeWatched == nil {
            problems.append("watched")
        }
        return problems
    }
    
    var body: some View {
        NavigationView {
            if missingInfo.isEmpty && duplicateEntries.isEmpty {
                Text("There are no problems in your library.")
                    .navigationBarTitle("Problems")
            } else {
                List {
                    if !missingInfo.isEmpty {
                        Section(header: Text("Missing Information")) {
                            ForEach(self.missingInfo) { mediaObject in
                                ProblemsLibraryRow(content: Text("Missing: \(checkProblems(mediaObject).joined(separator: ", "))").italic())
                                    .environmentObject(mediaObject)
                            }
                            .onDelete { indexSet in
                                for offset in indexSet {
                                    let id = self.missingInfo[offset].id
                                    self.library.remove(id: id)
                                }
                            }
                        }
                    }
                    if !duplicateEntries.isEmpty {
                        Section(header: Text("Duplicate Entries")) {
                            ForEach(self.duplicateEntries) { mediaObject in
                                ProblemsLibraryRow(content: Text("Duplicate").italic())
                                    .environmentObject(mediaObject)
                            }
                            .onDelete { indexSet in
                                for offset in indexSet {
                                    let id = self.duplicateEntries[offset].id
                                    self.library.remove(id: id)
                                }
                            }
                        }
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
