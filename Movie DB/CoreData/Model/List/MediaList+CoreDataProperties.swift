//
//  MediaList+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

extension MediaList {
    /// The name of the list
    @NSManaged public var name: String
    /// The name of the SF Symbol to use as an icon for this list
    @NSManaged public var iconName: String
    /// The filter setting of this media list
    @NSManaged public var filterSetting: FilterSetting?

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<MediaList> {
        NSFetchRequest<MediaList>(entityName: "List")
    }
}

extension MediaList: Identifiable {}
