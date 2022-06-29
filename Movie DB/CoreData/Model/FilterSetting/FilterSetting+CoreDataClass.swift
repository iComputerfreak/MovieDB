//
//  FilterSetting+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation
import SwiftUI

@objc(FilterSetting)
public class FilterSetting: NSManagedObject {
    var isReset: Bool {
        self.isAdult == nil &&
            self.mediaType == nil &&
            self.genres.isEmpty &&
            self.rating == nil &&
            self.year == nil &&
            self.statuses.isEmpty &&
            self.showTypes.isEmpty &&
            self.numberOfSeasons == nil &&
            self.watched == nil &&
            self.watchAgain == nil &&
            self.tags.isEmpty
    }
    
    convenience init(
        context: NSManagedObjectContext,
        id: UUID = UUID(),
        isAdult: Bool? = nil,
        mediaType: MediaType? = nil,
        rating: ClosedRange<StarRating>? = nil,
        year: ClosedRange<Int>? = nil,
        statuses: [MediaStatus] = [],
        showTypes: [ShowType] = [],
        numberOfSeasons: ClosedRange<Int>? = nil,
        watched: Bool? = nil,
        watchAgain: Bool? = nil,
        genres: Set<Genre> = [],
        tags: Set<Tag> = []
    ) {
        self.init(context: context)
        self.id = id
        self.isAdult = isAdult
        self.mediaType = mediaType
        minRating = rating?.lowerBound.rawValue
        maxRating = rating?.upperBound.rawValue
        minYear = year?.lowerBound
        maxYear = year?.upperBound
        self.statuses = statuses
        self.showTypes = showTypes
        minNumberOfSeasons = numberOfSeasons?.lowerBound
        maxNumberOfSeasons = numberOfSeasons?.upperBound
        self.watched = watched
        self.watchAgain = watchAgain
        self.genres = genres
        self.tags = tags
    }
    
    func reset() {
        isAdult = nil
        mediaType = nil
        genres = []
        rating = nil
        year = nil
        statuses = []
        showTypes = []
        numberOfSeasons = nil
        watched = nil
        watchAgain = nil
        tags = []
        assert(isReset, "FilterSetting is not in reset state after calling reset()")
    }
}

extension FilterSetting {
    /// Creates two proxies for the upper and lower bound of the given range Binding
    ///
    /// Ensures that the set values never exceed the given bounds and that the set values form a valid range (`lowerBound <= upperBound`)
    ///
    /// - Parameters:
    ///   - setting: The binding for the `ClosedRange` to create proxies from
    ///   - bounds: The bounds of the range
    static func rangeProxies<T>(
        for setting: Binding<ClosedRange<T>?>,
        bounds: ClosedRange<T>
    ) -> (lower: Binding<T>, upper: Binding<T>) {
        var lowerProxy: Binding<T> {
            Binding<T>(get: { setting.wrappedValue?.lowerBound ?? bounds.lowerBound }, set: { lower in
                // Ensure that we are not setting an illegal range
                var lower = max(lower, bounds.lowerBound)
                let upper = setting.wrappedValue?.upperBound ?? bounds.upperBound
                if lower > upper {
                    // Illegal range selected, set lower to lowest value possible
                    lower = upper
                }
                // Update the actual binding
                setting.wrappedValue = lower...upper
            })
        }
        
        var upperProxy: Binding<T> {
            Binding<T>(get: { setting.wrappedValue?.upperBound ?? bounds.upperBound }, set: { upper in
                let lower = setting.wrappedValue?.lowerBound ?? bounds.lowerBound
                var upper = min(upper, bounds.upperBound)
                if lower > upper {
                    // Illegal range selected
                    upper = lower
                }
                // Update the actual binding
                setting.wrappedValue = lower...upper
            })
        }
        
        return (lowerProxy, upperProxy)
    }
}

extension FilterSetting {
    /// Builds a predicate that represents the current filter configuration
    /// - Returns: The `NSCompoundPredicate` representing the current filter configuration
    // swiftlint:disable:next function_body_length
    func buildPredicate() -> NSPredicate {
        var predicates: [NSPredicate] = []
        if let isAdult = isAdult as NSNumber? {
            predicates.append(NSPredicate(format: "%K == %@", "isAdult", isAdult))
        }
        if let mediaType = mediaType {
            predicates.append(NSPredicate(format: "%K == %@", "type", mediaType.rawValue))
        }
        if !genres.isEmpty {
            // Any of the media's genres has to be in self.genres
            predicates.append(NSPredicate(format: "ANY %K IN %@", "genres", genres))
        }
        if let rating = rating {
            predicates.append(NSPredicate(
                format: "%K <= %d AND %K => %d",
                "personalRating",
                rating.upperBound.rawValue,
                "personalRating",
                rating.lowerBound.rawValue
            ))
        }
        if let year = year {
            let formatter = DateFormatter()
            // We don't care about the time, since all media objects only have a date set and the time is always zero.
            formatter.dateFormat = "yyyy-MM-dd"
            let lowerDate = formatter.date(from: "\(year.lowerBound.description)-01-01")! as NSDate
            // Our upper exclusive bound is the first day in the next year
            let upperDate = formatter.date(from: "\((year.upperBound + 1).description)-01-01")! as NSDate
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Movie
                NSPredicate(
                    format: "%K = %@ AND %K <= %@ AND %K => %@",
                    "type",
                    MediaType.movie.rawValue,
                    "releaseDate",
                    upperDate,
                    "releaseDate",
                    lowerDate
                ),
                // Show
                NSPredicate(
                    format: "%K = %@ AND %K <= %@ AND %K => %@",
                    "type",
                    MediaType.show.rawValue,
                    "firstAirDate",
                    upperDate,
                    "firstAirDate",
                    lowerDate
                ),
            ]))
        }
        if !statuses.isEmpty {
            predicates.append(NSPredicate(format: "%K IN %@", "status", statuses.map(\.rawValue)))
        }
        if !showTypes.isEmpty {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Show
                NSPredicate(
                    format: "%K == %@ AND %K IN %@",
                    "type",
                    MediaType.show.rawValue,
                    "showType",
                    showTypes.map(\.rawValue)
                ),
                // Movie
                NSPredicate(format: "%K == %@", "type", MediaType.movie.rawValue),
            ]))
        }
        if let numberOfSeasons = numberOfSeasons {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Show
                NSPredicate(
                    format: "%K == %@ AND %K <= %d AND %K >= %d",
                    "type",
                    MediaType.show.rawValue,
                    "numberOfSeasons",
                    numberOfSeasons.upperBound,
                    "numberOfSeasons",
                    numberOfSeasons.lowerBound
                ),
                // Movie
                NSPredicate(format: "%K == %@", "type", MediaType.movie.rawValue),
            ]))
        }
        // We need to cast Bool to NSNumber for the predicate to work
        if let watched = watched {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Movie
                NSPredicate(
                    format: "%K == %@ AND %K == %@",
                    "type",
                    MediaType.movie.rawValue,
                    "watchedState",
                    watched ? MovieWatchState.watched.rawValue : MovieWatchState.notWatched.rawValue
                ),
                // Show
                // watched == true && showWatchState != nil && showWatchState != 'notWatched'
                NSPredicate(
                    format: "%K == %@ AND %@ == TRUE AND %K != nil AND %K != %@",
                    "type", // ==
                    MediaType.show.rawValue,
                    watched as NSNumber, // == TRUE
                    "showWatchState", // != nil
                    "showWatchState", // !=
                    ShowWatchState.notWatched.rawValue
                ),
                // watched == true && showWatchState == 'notWatched'
                NSPredicate(
                    format: "%K == %@ AND %@ == FALSE AND %K = %@",
                    "type", // ==
                    MediaType.show.rawValue,
                    watched as NSNumber, // == FALSE
                    "showWatchState",
                    ShowWatchState.notWatched.rawValue
                ),
            ]))
        }
        if let watchAgain = watchAgain as NSNumber? {
            predicates.append(NSPredicate(format: "%K == %@", "watchAgain", watchAgain))
        }
        if !tags.isEmpty {
            predicates.append(NSPredicate(format: "ANY %K IN %@", "tags", tags))
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
