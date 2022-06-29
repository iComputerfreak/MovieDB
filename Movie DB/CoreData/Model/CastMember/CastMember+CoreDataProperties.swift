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

extension CastMember {
    public var id: Int {
        get { getInt(forKey: "id") }
        set { setInt(newValue, forKey: "id") }
    }
    /// The name of the actor
    @NSManaged public var name: String
    /// The name of the actor in the media
    @NSManaged public var roleName: String
    /// The path to an image of the actor on TMDB
    @NSManaged public var imagePath: String?
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CastMember> {
        NSFetchRequest<CastMember>(entityName: "CastMember")
    }
}

extension CastMember: Identifiable {}
