//
//  UserMediaList+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

public extension UserMediaList {
    @NSManaged var iconName: String
    @NSManaged var name: String
    @NSManaged var medias: Set<Media>

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<UserMediaList> {
        NSFetchRequest<UserMediaList>(entityName: "UserMediaList")
    }
}

extension UserMediaList: Identifiable {}
