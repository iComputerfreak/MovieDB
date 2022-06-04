//
//  Tag+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 07.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

extension Tag {
    /// The ID of the tag
    @NSManaged public var id: UUID
    /// The name of the tag
    @NSManaged public var name: String
    
    /// All media objects tagged with this tag
    @NSManaged public var medias: Set<Media>
    /// All ``FilterSetting``s that reference this tag
    @NSManaged public var filterSettings: Set<FilterSetting>
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Tag> {
        NSFetchRequest<Tag>(entityName: "Tag")
    }
}

extension Tag: Identifiable {}
