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
    /// The date and time of the last library update
    @NSManaged public var lastUpdated: Date?
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<MediaLibrary> {
        return NSFetchRequest<MediaLibrary>(entityName: "MediaLibrary")
    }
}
