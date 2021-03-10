//
//  MediaLibrary+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData


extension MediaLibrary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaLibrary> {
        return NSFetchRequest<MediaLibrary>(entityName: "MediaLibrary")
    }

    /// The next free ID
    public var nextID: Int {
        get {
            // Return the next id and increase it by one
            let next = getInt(forKey: "nextID")
            setInt(next + 1, forKey: "nextID")
            return next
        }
        set {
            setInt(newValue, forKey: "nextID")
        }
    }
    /// The next free Tag id
    public var nextTagID: Int {
        get {
            // Return the current ID and increase it by one
            let next = getInt(forKey: "nextTagID")
            self.nextTagID = next + 1
            return next
        }
        set { setInt(newValue, forKey: "nextTagID") }
    }
    
    /// The date and time of the last library update
    @NSManaged public var lastUpdated: Date?
    /// The list of media objects in this library
    @NSManaged public var mediaList: Set<Media>

}

// MARK: Generated accessors for mediaList
extension MediaLibrary {

    @objc(addMediaListObject:)
    @NSManaged public func addToMediaList(_ value: Media)

    @objc(removeMediaListObject:)
    @NSManaged public func removeFromMediaList(_ value: Media)

    @objc(addMediaList:)
    @NSManaged public func addToMediaList(_ values: NSSet)

    @objc(removeMediaList:)
    @NSManaged public func removeFromMediaList(_ values: NSSet)

}
