//
//  CastMember+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData


extension CastMember {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CastMember> {
        return NSFetchRequest<CastMember>(entityName: "CastMember")
    }

    @NSManaged public var id: Int64
    /// The name of the actor
    @NSManaged public var name: String
    /// The name of the actor in the media
    @NSManaged public var roleName: String
    /// The path to an image of the actor on TMDB
    @NSManaged public var imagePath: String?

}

extension CastMember : Identifiable {

}
