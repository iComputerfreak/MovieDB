//
//  UserMediaList+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation
import UIKit

public extension UserMediaList {
    /// The internal library id
    @NSManaged var id: UUID! // swiftlint:disable:this implicitly_unwrapped_optional
    /// The SF Symbols name of the icon of this media list
    @NSManaged var iconName: String
    /// The name of this media list
    @NSManaged var name: String

    var subtitleContent: LibraryRow.SubtitleContent? {
        get { getOptionalEnum(forKey: Schema.UserMediaList.subtitleContent, defaultValue: nil)}
        set { setOptionalEnum(newValue, forKey: Schema.UserMediaList.subtitleContent) }
    }

    /// The order in which to sort the medias inside the list
    var sortingOrder: SortingOrder {
        get { getEnum(forKey: Schema.UserMediaList.sortingOrder, defaultValue: .default) }
        set { setEnum(newValue, forKey: Schema.UserMediaList.sortingOrder) }
    }

    /// The direction in which to sort the medias in this list
    var sortingDirection: SortingDirection {
        get { getEnum(forKey: Schema.UserMediaList.sortingDirection, defaultValue: sortingOrder.defaultDirection) }
        set { setEnum(newValue, forKey: Schema.UserMediaList.sortingDirection) }
    }

    @NSManaged var medias: Set<Media>
    
    private var _iconColor: CDColor? {
        get { getOptional(forKey: Schema.UserMediaList.iconColor) }
        set { setOptional(newValue, forKey: Schema.UserMediaList.iconColor) }
    }
    
    var iconColor: UIColor? {
        get { _iconColor.map(UIColor.init(cdColor:)) }
        set { managedObjectContext.map { _iconColor.update(from: newValue, in: $0) } }
    }
    
    var iconRenderingMode: IconRenderingMode {
        get { getEnum(forKey: Schema.UserMediaList.iconRenderingMode, defaultValue: .hierarchical) }
        set { setEnum(newValue, forKey: Schema.UserMediaList.iconRenderingMode) }
    }

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<UserMediaList> {
        NSFetchRequest<UserMediaList>(entityName: Schema.UserMediaList._entityName)
    }
}

extension UserMediaList: Identifiable {}
