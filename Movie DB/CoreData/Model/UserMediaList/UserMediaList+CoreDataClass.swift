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
    override public var description: String {
        "UserMediaList(id: \(id.uuidString), name: \(name))"
    }
    
    func buildFetchRequest() -> NSFetchRequest<Media> {
        let fetch = Media.fetchRequest()
        fetch.predicate = NSPredicate(format: "%@ in %K", self, Schema.Media.userLists.rawValue)
        fetch.sortDescriptors = sortingOrder.createSortDescriptors(with: sortingDirection)
        return fetch
    }
    
    override public func awakeFromInsert() {
        self.id = UUID()
    }
}
