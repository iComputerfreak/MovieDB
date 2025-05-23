//
//  DynamicMediaList+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation
import UIKit

public extension DynamicMediaList {
    /// The internal library id
    @NSManaged var id: UUID?
    /// The name of the list
    @NSManaged var name: String
    /// The name of the SF Symbol to use as an icon for this list
    @NSManaged var iconName: String

    var subtitleContent: LibraryRow.SubtitleContent? {
        get { getOptionalEnum(forKey: Schema.DynamicMediaList.subtitleContent, defaultValue: nil)}
        set { setOptionalEnum(newValue, forKey: Schema.DynamicMediaList.subtitleContent) }
    }

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
    
    /// The color of the icon
    private var _iconColor: CDColor? {
        get { getOptional(forKey: Schema.DynamicMediaList.iconColor) }
        set { setOptional(newValue, forKey: Schema.DynamicMediaList.iconColor) }
    }
    
    var iconColor: UIColor? {
        get { _iconColor.map(UIColor.init(cdColor:)) }
        set { managedObjectContext.map { _iconColor.update(from: newValue, in: $0) } }
    }
    
    var iconRenderingMode: IconRenderingMode {
        get { getEnum(forKey: Schema.DynamicMediaList.iconRenderingMode, defaultValue: .hierarchical) }
        set { setEnum(newValue, forKey: Schema.DynamicMediaList.iconRenderingMode) }
    }

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<DynamicMediaList> {
        NSFetchRequest<DynamicMediaList>(entityName: Schema.DynamicMediaList._entityName)
    }
}

extension DynamicMediaList: Identifiable {}
