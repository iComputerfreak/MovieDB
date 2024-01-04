//
//  DynamicMediaList+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

@objc(DynamicMediaList)
public class DynamicMediaList: NSManagedObject, MediaListProtocol {
    override public var description: String {
        if isFault {
            return "\(String(describing: Self.self))(isFault: true, objectID: \(objectID))"
        } else {
            return "\(String(describing: Self.self))(id: \(id?.uuidString ?? "nil"), name: \(name))"
        }
    }
    
    func buildFetchRequest() -> NSFetchRequest<Media> {
        let fetch = Media.fetchRequest()
        fetch.predicate = filterSetting?.buildPredicate() ?? NSPredicate(value: true)
        fetch.sortDescriptors = sortingOrder.createNSSortDescriptors(with: sortingDirection)
        return fetch
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
        if filterSetting == nil {
            filterSetting = FilterSetting(context: managedObjectContext!)
        }
    }
}
