//
//  PredicateMediaList+Upcoming.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation

extension PredicateMediaList {
    enum Constants {
        static let pastOverscrollTime: TimeInterval = 14 * .day
    }

    static let upcoming = PredicateMediaList(
        name: Strings.Lists.defaultListNameUpcoming,
        // The user cannot set subtitle content for this list. It always displays a fixed value custom content type
        subtitleContentUserDefaultsKey: "upcomingSubtitleContent",
        defaultSubtitleContent: nil,
        description: Strings.Lists.upcomingDescription,
        iconName: "clock.badge.exclamationmark",
        predicate: NSCompoundPredicate(type: .or, subpredicates: [
            // MARK: Movies with future release date
            NSPredicate(
                format: "%K = %@ AND %K >= %@",
                Schema.Media.type,
                MediaType.movie.rawValue,
                // Will release in the future or has been released in the past 14 days
                Schema.Movie.releaseDate,
                NSDate(timeIntervalSinceNow: -Constants.pastOverscrollTime)
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
                // Only include shows where at least one season is in the future or has been released in the last 14 days
                return show.seasons
                    .compactMap(\.airDate)
                    .contains { $0 >= Date(timeIntervalSinceNow: -Constants.pastOverscrollTime) }
            }
            
            // Include all fetched movies
            return true
        },
        customSorting: { media1, media2 in
            // If any or all release dates are nil, only return true, if media1's is non-nil and media2's is nil
            // Otherwise they are equal or in the wrong order
            guard
                let release1 = media1.nextOrLatestReleaseDate,
                let release2 = media2.nextOrLatestReleaseDate
            else {
                return media1.nextOrLatestReleaseDate != nil && media2.nextOrLatestReleaseDate == nil
            }
            return release1 < release2
        }
    )
}
