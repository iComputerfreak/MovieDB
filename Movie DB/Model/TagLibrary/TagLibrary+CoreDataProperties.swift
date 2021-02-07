//
//  TagLibrary+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 07.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData


extension TagLibrary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TagLibrary> {
        return NSFetchRequest<TagLibrary>(entityName: "TagLibrary")
    }

    @NSManaged public var tags: Set<Tag>

}

// MARK: Generated accessors for tags
extension TagLibrary {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

extension TagLibrary : Identifiable {

}
