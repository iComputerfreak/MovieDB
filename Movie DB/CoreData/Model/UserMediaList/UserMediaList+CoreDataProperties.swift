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

extension UserMediaList {
    @NSManaged public var iconName: String
    @NSManaged public var name: String
    @NSManaged public var medias: Set<Media>

    @nonobjc
    public static func fetchRequest() -> NSFetchRequest<UserMediaList> {
        NSFetchRequest<UserMediaList>(entityName: "UserMediaList")
    }
}

extension UserMediaList: Identifiable {}
