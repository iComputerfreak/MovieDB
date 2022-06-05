//
//  FilterSetting+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

extension FilterSetting {
    @NSManaged public var id: UUID?
    public var isAdult: Bool? {
        get { getOptional(forKey: "isAdult") }
        set { setOptional(newValue, forKey: "watchAgain") }
    }
    public var mediaType: MediaType? {
        get { getOptionalEnum(forKey: "mediaType") }
        set { setOptionalEnum(newValue, forKey: "mediaType") }
    }
    public var minRating: Int? {
        get { getOptionalInt(forKey: "minRating") }
        set { setOptionalInt(newValue, forKey: "minRating") }
    }
    public var maxRating: Int? {
        get { getOptionalInt(forKey: "maxRating") }
        set { setOptionalInt(newValue, forKey: "maxRating") }
    }
    public var minYear: Int? {
        get { getOptionalInt(forKey: "minYear") }
        set { setOptionalInt(newValue, forKey: "minYear") }
    }
    public var maxYear: Int? {
        get { getOptionalInt(forKey: "maxYear") }
        set { setOptionalInt(newValue, forKey: "maxYear") }
    }
    public var statuses: [MediaStatus] {
        get { getEnumArray(forKey: "statuses") }
        set { setEnumArray(newValue, forKey: "statuses") }
    }
    public var showTypes: [ShowType] {
        get { getEnumArray(forKey: "showType") }
        set { setEnumArray(newValue, forKey: "showType") }
    }
    public var minNumberOfSeasons: Int? {
        get { getOptionalInt(forKey: "minNumberOfSeasons") }
        set { setOptionalInt(newValue, forKey: "minNumberOfSeasons") }
    }
    public var maxNumberOfSeasons: Int? {
        get { getOptionalInt(forKey: "maxNumberOfSeasons") }
        set { setOptionalInt(newValue, forKey: "maxNumberOfSeasons") }
    }
    public var watched: Bool? {
        get { getOptional(forKey: "watched") }
        set { setOptional(newValue, forKey: "watched") }
    }
    public var watchAgain: Bool? {
        get { getOptional(forKey: "watchAgain") }
        set { setOptional(newValue, forKey: "watchAgain") }
    }
    /// The genres that are referenced by this filter setting
    @NSManaged public var genres: Set<Genre>
    /// The tags that are referenced by this filter setting
    @NSManaged public var tags: Set<Tag>
    /// The media list that uses this filter setting
    @NSManaged public var mediaList: DynamicMediaList?
    
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

    @nonobjc
    public static func fetchRequest() -> NSFetchRequest<FilterSetting> {
        NSFetchRequest<FilterSetting>(entityName: "FilterSetting")
    }
}

extension FilterSetting: Identifiable {}
