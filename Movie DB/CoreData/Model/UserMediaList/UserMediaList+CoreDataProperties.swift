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

public extension UserMediaList {
    @NSManaged var iconName: String
    @NSManaged var name: String
    
    var sortingOrder: SortingOrder {
        get { getEnum(forKey: "sortingOrder", defaultValue: .default) }
        set { setEnum(newValue, forKey: "sortingOrder") }
    }

    var sortingDirection: SortingDirection {
        get { getEnum(forKey: "sortingDirection", defaultValue: sortingOrder.defaultDirection) }
        set { setEnum(newValue, forKey: "sortingDirection") }
    }

    @NSManaged var medias: Set<Media>

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<UserMediaList> {
        NSFetchRequest<UserMediaList>(entityName: "UserMediaList")
    }
}

extension UserMediaList: Identifiable {}
