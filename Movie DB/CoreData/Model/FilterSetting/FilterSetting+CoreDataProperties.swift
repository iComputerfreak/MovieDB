//
//  FilterSetting+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

public extension FilterSetting {
    @NSManaged var id: UUID?
    var isAdult: Bool? {
        get { getOptional(forKey: Schema.FilterSetting.isAdult) }
        set { setOptional(newValue, forKey: Schema.FilterSetting.watchAgain) }
    }

    var mediaType: MediaType? {
        get { getOptionalEnum(forKey: Schema.FilterSetting.mediaType) }
        set { setOptionalEnum(newValue, forKey: Schema.FilterSetting.mediaType) }
    }

    var minRating: Int? {
        // We return nil for negative numbers, since this property does not make sense for negative numbers
        // and we use -1 as an initial value when the entity is first created
        get {
            guard let value = getOptionalInt(forKey: Schema.FilterSetting.minRating), value >= 0 else {
                return nil
            }
            return value
        }
        set { setOptionalInt(newValue, forKey: Schema.FilterSetting.minRating) }
    }

    var maxRating: Int? {
        // We return nil for negative numbers, since this property does not make sense for negative numbers
        // and we use -1 as an initial value when the entity is first created
        get {
            guard let value = getOptionalInt(forKey: Schema.FilterSetting.maxRating), value >= 0 else {
                return nil
            }
            return value
        }
        set { setOptionalInt(newValue, forKey: Schema.FilterSetting.maxRating) }
    }

    var minYear: Int? {
        // We return nil for negative numbers, since this property does not make sense for negative numbers
        // and we use -1 as an initial value when the entity is first created
        get {
            guard let value = getOptionalInt(forKey: Schema.FilterSetting.minYear), value >= 0 else {
                return nil
            }
            return value
        }
        set { setOptionalInt(newValue, forKey: Schema.FilterSetting.minYear) }
    }

    var maxYear: Int? {
        // We return nil for negative numbers, since this property does not make sense for negative numbers
        // and we use -1 as an initial value when the entity is first created
        get {
            guard let value = getOptionalInt(forKey: Schema.FilterSetting.maxYear), value >= 0 else {
                return nil
            }
            return value
        }
        set { setOptionalInt(newValue, forKey: Schema.FilterSetting.maxYear) }
    }

    var statuses: [MediaStatus] {
        get { getEnumArray(forKey: Schema.FilterSetting.statuses) }
        set { setEnumArray(newValue, forKey: Schema.FilterSetting.statuses) }
    }

    var showTypes: [ShowType] {
        get { getEnumArray(forKey: Schema.FilterSetting.showTypes) }
        set { setEnumArray(newValue, forKey: Schema.FilterSetting.showTypes) }
    }

    var minNumberOfSeasons: Int? {
        // We return nil for negative numbers, since this property does not make sense for negative numbers
        // and we use -1 as an initial value when the entity is first created
        get {
            guard let value = getOptionalInt(forKey: Schema.FilterSetting.minNumberOfSeasons), value >= 0 else {
                return nil
            }
            return value
        }
        set { setOptionalInt(newValue, forKey: Schema.FilterSetting.minNumberOfSeasons) }
    }

    var maxNumberOfSeasons: Int? {
        // We return nil for negative numbers, since this property does not make sense for negative numbers
        // and we use -1 as an initial value when the entity is first created
        get {
            guard let value = getOptionalInt(forKey: Schema.FilterSetting.maxNumberOfSeasons), value >= 0 else {
                return nil
            }
            return value
        }
        set { setOptionalInt(newValue, forKey: Schema.FilterSetting.maxNumberOfSeasons) }
    }

    var watched: Bool? {
        get { getOptional(forKey: Schema.FilterSetting.watched) }
        set { setOptional(newValue, forKey: Schema.FilterSetting.watched) }
    }

    var watchAgain: Bool? {
        get { getOptional(forKey: Schema.FilterSetting.watchAgain) }
        set { setOptional(newValue, forKey: Schema.FilterSetting.watchAgain) }
    }

    /// The genres that are referenced by this filter setting
    @NSManaged var genres: Set<Genre>
    /// The tags that are referenced by this filter setting
    @NSManaged var tags: Set<Tag>
    /// The media list that uses this filter setting
    @NSManaged var mediaList: DynamicMediaList?
    
    internal var rating: ClosedRange<StarRating>? {
        get {
            guard
                let rawMinRating = minRating, let minRating = StarRating(rawValue: rawMinRating),
                let rawMaxRating = maxRating, let maxRating = StarRating(rawValue: rawMaxRating)
            else {
                return nil
            }
            return minRating...maxRating
        }
        set {
            minRating = newValue?.lowerBound.rawValue
            maxRating = newValue?.upperBound.rawValue
        }
    }
    
    internal var year: ClosedRange<Int>? {
        get {
            guard let minYear, let maxYear else {
                return nil
            }
            return minYear...maxYear
        }
        set {
            minYear = newValue?.lowerBound
            maxYear = newValue?.upperBound
        }
    }
    
    internal var numberOfSeasons: ClosedRange<Int>? {
        get {
            guard
                let minNumberOfSeasons,
                let maxNumberOfSeasons
            else {
                return nil
            }
            return minNumberOfSeasons...maxNumberOfSeasons
        }
        set {
            minNumberOfSeasons = newValue?.lowerBound
            maxNumberOfSeasons = newValue?.upperBound
        }
    }

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<FilterSetting> {
        NSFetchRequest<FilterSetting>(entityName: Schema.FilterSetting._entityName)
    }
}

extension FilterSetting: Identifiable {}
