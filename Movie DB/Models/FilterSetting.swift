//
//  FilterSetting.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct FilterSetting: Identifiable {
    var id = UUID()
    
    var isAdult: Bool?
    var mediaType: MediaType?
    /// Use computed property ``rating`` instead
    private var minRating: Int?
    /// Use computed property ``rating`` instead
    private var maxRating: Int?
    /// Use computed property ``year`` instead
    private var minYear: Int?
    /// Use computed property ``year`` instead
    private var maxYear: Int?
    var statuses: [MediaStatus] = []
    var showTypes: [ShowType] = []
    /// Use computed property ``numberOfSeasons`` instead
    private var minNumberOfSeasons: Int?
    /// Use computed property ``numberOfSeasons`` instead
    private var maxNumberOfSeasons: Int?
    var watched: Bool?
    var watchAgain: Bool?
    var genres: Set<Genre> = []
    var tags: Set<Tag> = []
    
    var rating: ClosedRange<StarRating>? {
        get {
            guard let rawMinRating = self.minRating, let minRating = StarRating(rawValue: rawMinRating),
                  let rawMaxRating = self.maxRating, let maxRating = StarRating(rawValue: rawMaxRating) else {
                return nil
            }
            return minRating ... maxRating
        }
        set {
            self.minRating = newValue?.lowerBound.rawValue
            self.maxRating = newValue?.upperBound.rawValue
        }
    }
    
    var year: ClosedRange<Int>? {
        get {
            guard let minYear = self.minYear, let maxYear = self.maxYear else {
                return nil
            }
            return minYear ... maxYear
        }
        set {
            self.minYear = newValue?.lowerBound
            self.maxYear = newValue?.upperBound
        }
    }
    
    var numberOfSeasons: ClosedRange<Int>? {
        get {
            guard
                let minNumberOfSeasons = self.minNumberOfSeasons,
                let maxNumberOfSeasons = self.maxNumberOfSeasons
            else {
                return nil
            }
            return minNumberOfSeasons ... maxNumberOfSeasons
        }
        set {
            self.minNumberOfSeasons = newValue?.lowerBound
            self.maxNumberOfSeasons = newValue?.upperBound
        }
    }
    
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
    
    mutating func reset() {
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
}

extension FilterSetting {
    /// Builds a predicate that represents the current filter configuration
    /// - Returns: The `NSCompoundPredicate` representing the current filter configuration
    // swiftlint:disable:next function_body_length
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
                )
            ]))
        }
        if !self.statuses.isEmpty {
            predicates.append(NSPredicate(format: "%K IN %@", "status", statuses.map(\.rawValue)))
        }
        if !self.showTypes.isEmpty {
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
        if let watched = self.watched {
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
                // watched == true && lastSeasonWatched != nil
                NSPredicate(
                    format: "%K == %@ AND %@ == TRUE AND %K != nil",
                    "type",
                    MediaType.show.rawValue,
                    watched as NSNumber,
                    "lastSeasonWatched"
                ),
                // watched == false && lastSeasonWatched == nil
                NSPredicate(
                    format: "%K == %@ AND %@ == FALSE AND %K = nil",
                    "type",
                    MediaType.show.rawValue,
                    watched as NSNumber,
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
}

extension FilterSetting {
    init(
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
        self.init(
            id: id,
            isAdult: isAdult,
            mediaType: mediaType,
            minRating: rating?.lowerBound.rawValue,
            maxRating: rating?.upperBound.rawValue,
            minYear: year?.lowerBound,
            maxYear: year?.upperBound,
            statuses: statuses,
            showTypes: showTypes,
            minNumberOfSeasons: numberOfSeasons?.lowerBound,
            maxNumberOfSeasons: numberOfSeasons?.upperBound,
            watched: watched,
            watchAgain: watchAgain,
            genres: genres,
            tags: tags
        )
    }
}
