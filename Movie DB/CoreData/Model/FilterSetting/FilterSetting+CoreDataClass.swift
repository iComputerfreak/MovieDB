//
//  FilterSetting+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import Combine
import CoreData
import Foundation
import SwiftUI

@objc(FilterSetting)
public class FilterSetting: NSManagedObject {
    static let shared: FilterSetting = {
        // Create a new FilterSetting (will be saved in the viewContext and cleaned up later at app start)
        let newFilterSetting = FilterSetting(with: PersistenceController.viewContext)
        PersistenceController.saveContext()
        return newFilterSetting
    }()
    
    override public var description: String {
        if isFault {
            return "\(String(describing: Self.self))(isFault: true, objectID: \(objectID))"
        } else {
            return "\(String(describing: Self.self))(id: \(id?.uuidString ?? "nil"))"
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
            self.tags.isEmpty &&
            self.watchProviders.isEmpty
    }
    
    private var parentNotificationSubscription: AnyCancellable?
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        // If this FilterSetting changes, we notify its associated media list, if there is any
        self.parentNotificationSubscription = self.objectWillChange.sink {
            self.mediaList?.objectWillChange.send()
        }
    }
        
    convenience init(
        with context: NSManagedObjectContext,
        id: UUID = UUID(),
        isAdult: Bool? = nil,
        mediaType: MediaType? = nil,
        rating: ClosedRange<StarRating>? = nil,
        year: ClosedRange<Int>? = nil,
        statuses: [MediaStatus] = [],
        showTypes: [ShowType] = [],
        numberOfSeasons: ClosedRange<Int>? = nil,
        watched: FilterWatchState? = nil,
        watchAgain: Bool? = nil,
        genres: Set<Genre> = [],
        tags: Set<Tag> = [],
        watchProviders: Set<WatchProvider> = []
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
        self.watchProviders = watchProviders
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
        watchProviders = []
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
    func buildPredicate() -> NSPredicate { // swiftlint:disable:this function_body_length
        var predicates: [NSPredicate] = []
        if let isAdult = isAdult as NSNumber? {
            predicates.append(NSPredicate(format: "%K == %@", Schema.Movie.isAdult.rawValue, isAdult))
        }
        if let mediaType {
            predicates.append(NSPredicate(format: "%K == %@", Schema.Media.type.rawValue, mediaType.rawValue))
        }
        if !genres.isEmpty {
            // Any of the media's genres has to be in self.genres
            predicates.append(NSPredicate(format: "ANY %K IN %@", Schema.Media.genres.rawValue, genres))
        }
        if let rating {
            predicates.append(NSPredicate(
                format: "%K <= %d AND %K => %d",
                Schema.Media.personalRating.rawValue,
                rating.upperBound.rawValue,
                Schema.Media.personalRating.rawValue,
                rating.lowerBound.rawValue
            ))
        }
        if let year {
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
                    Schema.Media.type.rawValue,
                    MediaType.movie.rawValue,
                    Schema.Movie.releaseDate.rawValue,
                    upperDate,
                    Schema.Movie.releaseDate.rawValue,
                    lowerDate
                ),
                // Show
                NSPredicate(
                    format: "%K = %@ AND %K <= %@ AND %K => %@",
                    Schema.Media.type.rawValue,
                    MediaType.show.rawValue,
                    Schema.Show.firstAirDate.rawValue,
                    upperDate,
                    Schema.Show.firstAirDate.rawValue,
                    lowerDate
                ),
            ]))
        }
        if !statuses.isEmpty {
            predicates.append(NSPredicate(format: "%K IN %@", Schema.Media.status.rawValue, statuses.map(\.rawValue)))
        }
        if !showTypes.isEmpty {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Show
                NSPredicate(
                    format: "%K == %@ AND %K IN %@",
                    Schema.Media.type.rawValue,
                    MediaType.show.rawValue,
                    Schema.Show.showType.rawValue,
                    showTypes.map(\.rawValue)
                ),
                // Movie
                NSPredicate(format: "%K == %@", Schema.Media.type.rawValue, MediaType.movie.rawValue),
            ]))
        }
        if let numberOfSeasons {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                // Show
                NSPredicate(
                    format: "%K == %@ AND %K <= %d AND %K >= %d",
                    Schema.Media.type.rawValue,
                    MediaType.show.rawValue,
                    Schema.Show.numberOfSeasons.rawValue,
                    numberOfSeasons.upperBound,
                    Schema.Show.numberOfSeasons.rawValue,
                    numberOfSeasons.lowerBound
                ),
                // Movie
                NSPredicate(format: "%K == %@", Schema.Media.type.rawValue, MediaType.movie.rawValue),
            ]))
        }
        func movieWatchState(for watchState: FilterWatchState) -> MovieWatchState? {
            // swiftlint:disable switch_case_on_newline
            switch watchState {
            case .watched: return .watched
            case .watchedFully: return .watched
            case .partially: return .partially
            case .notWatched: return .notWatched
            case .unknown: return nil
            }
            // swiftlint:enable switch_case_on_newline
        }
        // We need to cast Bool to NSNumber for the predicate to work
        if let watched {
            // MARK: Movie
            // swiftlint:disable:next implicitly_unwrapped_optional
            let moviePredicate: NSPredicate!
            if let movieWatchState = movieWatchState(for: watched) {
                moviePredicate = NSPredicate(
                    format: "%K == %@ AND %K == %@",
                    Schema.Media.type.rawValue,
                    MediaType.movie.rawValue,
                    Schema.Movie.watchedState.rawValue,
                    movieWatchState.rawValue
                )
            } else {
                moviePredicate = NSPredicate(
                    format: "%K == %@ AND %K == nil",
                    Schema.Media.type.rawValue,
                    MediaType.movie.rawValue,
                    Schema.Movie.watchedState.rawValue
                )
            }
            
            let showPredicate: NSPredicate = {
                switch watched {
                case .notWatched:
                    return ShowWatchState.showsNotWatchedPredicate
                case .unknown:
                    return ShowWatchState.showsWatchedUnknownPredicate
                case .watched:
                    return ShowWatchState.showsWatchedAnyPredicate
                case .watchedFully:
                    return ShowWatchState.showsWatchedAllSeasonsPredicate
                case .partially:
                    return ShowWatchState.showsWatchedPartiallyPredicate
                }
            }()
            
            predicates.append(NSCompoundPredicate(type: .or, subpredicates: [moviePredicate, showPredicate]))
        }
        if let watchAgain = watchAgain as NSNumber? {
            predicates.append(NSPredicate(format: "%K == %@", Schema.Media.watchAgain.rawValue, watchAgain))
        }
        if !tags.isEmpty {
            predicates.append(NSPredicate(format: "ANY %K IN %@", Schema.Media.tags.rawValue, tags))
        }
        if !watchProviders.isEmpty {
            // If any of the media's watch providers is in the filter's watch providers
            predicates.append(NSPredicate(format: "ANY %K IN %@", Schema.Media.watchProviders.rawValue, watchProviders))
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
