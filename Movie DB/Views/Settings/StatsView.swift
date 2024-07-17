//
//  StatsView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.01.24.
//  Copyright © 2024 Jonas Frey. All rights reserved.
//

import CoreData
import OSLog
import SwiftUI

struct StatsView: View {
    // TODO: Pro only
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var totalMedias: Int {
        totalMovies + totalShows
    }
    
    var totalMovies: Int {
        count(for: Movie.fetchRequest())
    }
    
    var totalShows: Int {
        count(for: Show.fetchRequest())
    }
    
    var totalSeasons: Int {
        count(for: Season.fetchRequest())
    }
    
    var moviesWatched: Int {
        let fetchRequest: NSFetchRequest = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K = %@",
            Schema.Movie.watchedState.rawValue,
            MovieWatchState.watched.rawValue
        )
        return count(for: fetchRequest)
    }
    
    var showsWatched: Int {
        0
    }
    
    var seasonsWatched: Int {
        0
    }
    
    var totalWatchTime: Duration {
        Duration(secondsComponent: 365 * 3600, attosecondsComponent: 0)
    }
    
    var totalWatchTimeString: String {
        totalWatchTime
            .formatted(.units(
                allowed: [.hours],
                width: .wide,
                maximumUnitCount: 1,
                zeroValueUnits: .show(length: 1),
                valueLength: nil,
                fractionalPart: .hide
            ))
    }
    
    let bodyFont: Font = .body
    
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Number of Medias: \(totalMedias)")
                    Text("\tMovies: \(totalMovies)")
                    Text("\tTV Shows: \(totalShows) (\(totalSeasons) seasons)")
                    Text("")
                    Text("Movies watched: \(moviesWatched)")
                    Text("TV Shows watched: \(moviesWatched) (\(seasonsWatched) seasons)")
                    Text("")
                    Text("Total watch time: \(totalWatchTimeString)")
                    Spacer(minLength: 0)
                }
                .font(.body)
                .padding()
                Spacer(minLength: 0)
            }
        }
        .navigationTitle("Stats")
    }
    
    private func count(for fetchRequest: NSFetchRequest<some NSManagedObject>) -> Int {
        do {
            return try managedObjectContext.count(for: fetchRequest)
        } catch {
            Logger.coreData.error("Error counting results of fetch request \(fetchRequest, privacy: .public)")
            return 0
        }
    }
}

#Preview {
    NavigationStack {
        StatsView()
            .previewEnvironment()
    }
}
