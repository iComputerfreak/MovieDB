//
//  Genre+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData


extension Genre {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Genre> {
        return NSFetchRequest<Genre>(entityName: "Genre")
    }

    /// The ID of the genre on TMDB
    public var id: Int {
        get { getInt(forKey: "id") }
        set { setInt(newValue, forKey: "id") }
    }
    /// The name of the genre
    @NSManaged public var name: String
    @NSManaged public var medias: Set<Media>

}

// MARK: Generated accessors for medias
extension Genre {
    
    @objc(addMediasObject:)
    @NSManaged public func addToMedias(_ value: Media)
    
    @objc(removeMediasObject:)
    @NSManaged public func removeFromMedias(_ value: Media)
    
    @objc(addMedias:)
    @NSManaged public func addToMedias(_ values: NSSet)
    
    @objc(removeMedias:)
    @NSManaged public func removeFromMedias(_ values: NSSet)
    
}

extension Genre : Identifiable {

}
