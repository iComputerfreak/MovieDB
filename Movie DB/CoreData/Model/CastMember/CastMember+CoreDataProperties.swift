//
//  CastMember+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

public extension CastMember {
    var id: Int {
        get { getInt(forKey: "id") }
        set { setInt(newValue, forKey: "id") }
    }

    /// The name of the actor
    @NSManaged var name: String
    /// The name of the actor in the media
    @NSManaged var roleName: String
    /// The path to an image of the actor on TMDB
    @NSManaged var imagePath: String?
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<CastMember> {
        NSFetchRequest<CastMember>(entityName: "CastMember")
    }
}

extension CastMember: Identifiable {}
