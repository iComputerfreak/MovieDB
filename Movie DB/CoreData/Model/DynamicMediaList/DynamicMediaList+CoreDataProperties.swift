//
//  MediaList+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

public extension DynamicMediaList {
    /// The internal library id
    @NSManaged var id: UUID! // swiftlint:disable:this implicitly_unwrapped_optional
    /// The name of the list
    @NSManaged var name: String
    /// The name of the SF Symbol to use as an icon for this list
    @NSManaged var iconName: String
    
    var sortingOrder: SortingOrder {
        get { getEnum(forKey: Schema.DynamicMediaList.sortingOrder, defaultValue: .default) }
        set { setEnum(newValue, forKey: Schema.DynamicMediaList.sortingOrder) }
    }
    
    var sortingDirection: SortingDirection {
        get { getEnum(forKey: Schema.DynamicMediaList.sortingDirection, defaultValue: sortingOrder.defaultDirection) }
        set { setEnum(newValue, forKey: Schema.DynamicMediaList.sortingDirection) }
    }
    
    /// The filter setting of this media list
    @NSManaged var filterSetting: FilterSetting?

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<DynamicMediaList> {
        NSFetchRequest<DynamicMediaList>(entityName: Schema.DynamicMediaList._entityName)
    }
}

extension DynamicMediaList: Identifiable {}
