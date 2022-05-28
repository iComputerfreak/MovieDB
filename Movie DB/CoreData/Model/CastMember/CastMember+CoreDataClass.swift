//
//  CastMember+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

/// Represents an actor starring in a specific movie
@objc(CastMember)
public class CastMember: NSManagedObject {
    // MARK: - Initializers
    
    public convenience init(
        context: NSManagedObjectContext,
        id: Int,
        name: String,
        roleName: String,
        imagePath: String? = nil
    ) {
        self.init(context: context)
        self.id = id
        self.name = name
        self.roleName = roleName
        self.imagePath = imagePath
    }
}
