//
//  Genre+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

public extension Genre {
    /// The ID of the genre on TMDB
    var id: Int {
        get { getInt(forKey: "id") }
        set { setInt(newValue, forKey: "id") }
    }

    /// The name of the genre
    @NSManaged var name: String
    @NSManaged var medias: Set<Media>
    /// All ``FilterSetting``s that reference this genre
    @NSManaged var filterSettings: Set<FilterSetting>
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Genre> { NSFetchRequest<Genre>(entityName: "Genre") }
}

extension Genre: Identifiable {}
