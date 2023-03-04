//
//  Tag+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 07.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

public extension Tag {
    /// The ID of the tag
    @NSManaged var id: UUID?
    /// The name of the tag
    @NSManaged var name: String
    
    /// All media objects tagged with this tag
    @NSManaged var medias: Set<Media>
    /// All ``FilterSetting``s that reference this tag
    @NSManaged var filterSettings: Set<FilterSetting>
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Tag> {
        NSFetchRequest<Tag>(entityName: Schema.Tag._entityName)
    }
}

extension Tag: Identifiable {}
