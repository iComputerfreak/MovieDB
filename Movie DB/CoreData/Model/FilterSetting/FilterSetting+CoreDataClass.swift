//
//  FilterSetting+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 31.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftUI

@objc(FilterSetting)
public class FilterSetting: NSManagedObject {
    static let shared: FilterSetting = {
        let context = PersistenceController.viewContext
        let fetchRequest: NSFetchRequest<FilterSetting> = FilterSetting.fetchRequest()
        fetchRequest.fetchLimit = 1
        let results = try? context.fetch(fetchRequest)
        assert((results?.count ?? 0) <= 1)
        // Return the fetched result or create a new one
        return results?.first ?? FilterSetting(context: context)
    }()
    
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
                // Update the binding in the main thread (may be bound to UI)
                DispatchQueue.main.async {
                    setting.wrappedValue = lower ... upper
                }
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
                // Update the binding in the main thread (may be bound to UI)
                DispatchQueue.main.async {
                    setting.wrappedValue = lower ... upper
                }
            })
        }

        return (lowerProxy, upperProxy)
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.genres = []
        self.tags = []
        self.showTypes = []
        self.statuses = []
    }
    
    /// Builds a predicate that represents the current filter configuration
    /// - Returns: The `NSCompoundPredicate` representing the current filter configuration
    func predicate() -> NSPredicate {
        var predicates: [NSPredicate] = []
        if let isAdult = self.isAdult as NSNumber? {
            predicates.append(NSPredicate(format: "%K == %@", "isAdult", isAdult))
        }
        if let mediaType = self.mediaType {
            predicates.append(NSPredicate(format: "%K == %@", "type", mediaType.rawValue))
        }
        if !self.genres.isEmpty {
            // Any of the media's genres has to be in self.genres
            predicates.append(NSPredicate(format: "ANY %K IN %@", "genres", genres))
        }
        if let rating = self.rating {
            predicates.append(NSPredicate(
                format: "%K <= %d AND %K => %d",
                "personalRating",
                rating.upperBound.rawValue,
                "personalRating",
                rating.lowerBound.rawValue
            ))
        }
        if let year = self.year {
            let formatter = DateFormatter()
            // We don't care about the time, since all media objects only have a date set and the time is always zero.
            formatter.dateFormat = "yyyy-MM-dd"
            let lowerDate = formatter.date(from: "\(year.lowerBound)-01-01")! as NSDate
            // Our upper exclusive bound is the first day in the next year
            let upperDate = formatter.date(from: "\(year.upperBound + 1)-01-01")! as NSDate
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Movie
                NSPredicate(format: "%K <= %@ AND %K => %@", "releaseDate", upperDate, "releaseDate", lowerDate),
                // Show
                NSPredicate(format: "%K <= %@ AND %K => %@", "firstAirDate", upperDate, "firstAirDate", lowerDate)
            ]))
        }
        if !self.statuses.isEmpty {
            predicates.append(NSPredicate(format: "%K IN %@", "status", statuses.map(\.rawValue)))
        }
        if !self.showTypes.isEmpty {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Show
                NSPredicate(format: "%K IN %@", "showType", showTypes.map(\.rawValue)),
                // Movie
                NSPredicate(format: "%K == %@", "type", MediaType.movie.rawValue)
            ]))
        }
        if let numberOfSeasons = self.numberOfSeasons {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Show
                NSPredicate(
                    format: "%K == %@ AND %K < %d AND %K > %d",
                    "type",
                    MediaType.show.rawValue,
                    "numberOfSeasons",
                    numberOfSeasons.upperBound,
                    "numberOfSeasons",
                    numberOfSeasons.lowerBound
                )
            ]))
        }
        // We need to cast Bool to NSNumber for the predicate to work
        if let watched = self.watched as NSNumber? {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Movie
                NSPredicate(format: "%K == %@", "watched", watched),
                // Show
                // watched == true && lastSeasonWatched != nil
                NSPredicate(
                    format: "%K == %@ AND %@ == TRUE AND %K != nil",
                    "type",
                    MediaType.show.rawValue,
                    watched,
                    "lastSeasonWatched"
                ),
                // watched == false && lastSeasonWatched == nil
                NSPredicate(
                    format: "%K == %@ AND %@ == FALSE AND %K = nil",
                    "type",
                    MediaType.show.rawValue,
                    watched,
                    "lastSeasonWatched"
                )
            ]))
        }
        if let watchAgain = self.watchAgain as NSNumber? {
            predicates.append(NSPredicate(format: "%K == %@", "watchAgain", watchAgain))
        }
        if !self.tags.isEmpty {
            predicates.append(NSPredicate(format: "ANY %K IN %@", "tags", tags))
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    func reset() {
        self.isAdult = nil
        self.mediaType = nil
        self.genres = []
        self.rating = nil
        self.year = nil
        self.statuses = []
        self.showTypes = []
        self.numberOfSeasons = nil
        self.watched = nil
        self.watchAgain = nil
        self.tags = []
        assert(self.isReset, "FilterSetting is not in reset state after calling reset()")
    }
}
