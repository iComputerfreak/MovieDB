//
//  PredicateMediaList+Upcoming.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation

extension PredicateMediaList {
    static let upcoming = PredicateMediaList(
        name: Strings.Lists.defaultListNameUpcoming,
        description: Strings.Lists.upcomingDescription,
        iconName: "clock.badge.exclamationmark",
        predicate: NSCompoundPredicate(type: .or, subpredicates: [
            // MARK: Movies with future release date
            NSPredicate(
                format: "%K = %@ AND %K > %@",
                Schema.Media.type,
                MediaType.movie.rawValue,
                Schema.Movie.releaseDate,
                NSDate()
            ),
            
            // MARK: Seasons with a future season
            NSCompoundPredicate(type: .and, subpredicates: [
                NSPredicate(
                    format: "%K = %@",
                    Schema.Media.type,
                    MediaType.show.rawValue
                ),
                // !!!: We use the same predicate filtering here as in the "New Seasons" list.
                // Include shows with unwatched seasons that are not marked as "Watch again / continue?" = "No".
                // The main point of difference between the two lists is that this one includes movies and the custom filter.
                NSPredicate(
                    format: "%K < %K",
                    Schema.Show.lastSeasonWatched,
                    Schema.Show.numberOfSeasons
                ),
                
                // Don't include shows marked as "Watch Again?" = false
                NSPredicate(
                    format: "%K = %@ OR %K = nil",
                    Schema.Media.watchAgain,
                    true as NSNumber,
                    Schema.Media.watchAgain
                ),
            ]),
        ]),
        customFilter: { media in
            if let show = media as? Show {
                // Only include shows where at least one season is in the future
                return show.seasons.compactMap(\.airDate).contains { $0 > .now }
            }
            
            // Include all fetched movies
            return true
        }
    )
}
