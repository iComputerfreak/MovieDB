//
//  UserMediaList+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

@objc(UserMediaList)
public class UserMediaList: NSManagedObject, MediaListProtocol {
    func buildFetchRequest() -> NSFetchRequest<Media> {
        let fetch = Media.fetchRequest()
        fetch.predicate = NSPredicate(format: "%@ in %K", self, "userLists")
        // TODO: Use stored sorting direction and order
        fetch.sortDescriptors = []
        return fetch
    }
}
