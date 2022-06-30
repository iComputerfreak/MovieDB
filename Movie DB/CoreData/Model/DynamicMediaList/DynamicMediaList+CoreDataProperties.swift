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
    /// The name of the list
    @NSManaged var name: String
    /// The name of the SF Symbol to use as an icon for this list
    @NSManaged var iconName: String
    
    var sortingOrder: SortingOrder {
        get { getEnum(forKey: "sortingOrder", defaultValue: .default) }
        set { setEnum(newValue, forKey: "sortingOrder") }
    }
    
    var sortingDirection: SortingDirection {
        get { getEnum(forKey: "sortingDirection", defaultValue: sortingOrder.defaultDirection) }
        set { setEnum(newValue, forKey: "sortingDirection") }
    }
    
    /// The filter setting of this media list
    @NSManaged var filterSetting: FilterSetting?

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<DynamicMediaList> {
        NSFetchRequest<DynamicMediaList>(entityName: "DynamicMediaList")
    }
}

extension DynamicMediaList: Identifiable {}
