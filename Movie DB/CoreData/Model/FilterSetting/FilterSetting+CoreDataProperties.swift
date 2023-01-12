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
        get { getOptional(forKey: "isAdult") }
        set { setOptional(newValue, forKey: "watchAgain") }
    }

    var mediaType: MediaType? {
        get { getOptionalEnum(forKey: "mediaType") }
        set { setOptionalEnum(newValue, forKey: "mediaType") }
    }

    var minRating: Int? {
        // We return nil for negative numbers, since this property does not make sense for negative numbers
        // and we use -1 as an initial value when the entity is first created
        get {
            guard let value = getOptionalInt(forKey: "minRating"), value >= 0 else {
                return nil
            }
            return value
        }
        set { setOptionalInt(newValue, forKey: "minRating") }
    }

    var maxRating: Int? {
        // We return nil for negative numbers, since this property does not make sense for negative numbers
        // and we use -1 as an initial value when the entity is first created
        get {
            guard let value = getOptionalInt(forKey: "maxRating"), value >= 0 else {
                return nil
            }
            return value
        }
        set { setOptionalInt(newValue, forKey: "maxRating") }
    }

    var minYear: Int? {
        // We return nil for negative numbers, since this property does not make sense for negative numbers
        // and we use -1 as an initial value when the entity is first created
        get {
            guard let value = getOptionalInt(forKey: "minYear"), value >= 0 else {
                return nil
            }
            return value
        }
        set { setOptionalInt(newValue, forKey: "minYear") }
    }

    var maxYear: Int? {
        // We return nil for negative numbers, since this property does not make sense for negative numbers
        // and we use -1 as an initial value when the entity is first created
        get {
            guard let value = getOptionalInt(forKey: "maxYear"), value >= 0 else {
                return nil
            }
            return value
        }
        set { setOptionalInt(newValue, forKey: "maxYear") }
    }

    var statuses: [MediaStatus] {
        get { getEnumArray(forKey: "statuses") }
        set { setEnumArray(newValue, forKey: "statuses") }
    }

    var showTypes: [ShowType] {
        get { getEnumArray(forKey: "showTypes") }
        set { setEnumArray(newValue, forKey: "showTypes") }
    }

    var minNumberOfSeasons: Int? {
        // We return nil for negative numbers, since this property does not make sense for negative numbers
        // and we use -1 as an initial value when the entity is first created
        get {
            guard let value = getOptionalInt(forKey: "minNumberOfSeasons"), value >= 0 else {
                return nil
            }
            return value
        }
        set { setOptionalInt(newValue, forKey: "minNumberOfSeasons") }
    }

    var maxNumberOfSeasons: Int? {
        // We return nil for negative numbers, since this property does not make sense for negative numbers
        // and we use -1 as an initial value when the entity is first created
        get {
            guard let value = getOptionalInt(forKey: "maxNumberOfSeasons"), value >= 0 else {
                return nil
            }
            return value
        }
        set { setOptionalInt(newValue, forKey: "maxNumberOfSeasons") }
    }

    var watched: Bool? {
        get { getOptional(forKey: "watched") }
        set { setOptional(newValue, forKey: "watched") }
    }

    var watchAgain: Bool? {
        get { getOptional(forKey: "watchAgain") }
        set { setOptional(newValue, forKey: "watchAgain") }
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
        NSFetchRequest<FilterSetting>(entityName: "FilterSetting")
    }
}

extension FilterSetting: Identifiable {}
