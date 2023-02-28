//
//  List+CoreDataClass.swift
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
        "DynamicMediaList(id: \(id.uuidString), name: \(name))"
    }
    
    func buildFetchRequest() -> NSFetchRequest<Media> {
        let fetch = Media.fetchRequest()
        fetch.predicate = filterSetting?.buildPredicate() ?? NSPredicate(value: true)
        fetch.sortDescriptors = sortingOrder.createSortDescriptors(with: sortingDirection)
        return fetch
    }
    
    override public func awakeFromInsert() {
        self.id = UUID()
        if filterSetting == nil {
            filterSetting = FilterSetting(context: managedObjectContext!)
        }
    }
}
