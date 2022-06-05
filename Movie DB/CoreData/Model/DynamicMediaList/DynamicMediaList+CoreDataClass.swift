//
//  List+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

@objc(DynamicMediaList)
public class DynamicMediaList: NSManagedObject, MediaListProtocol {
    func buildFetchRequest() -> NSFetchRequest<Media> {
        let fetch = Media.fetchRequest()
        fetch.predicate = NSPredicate(value: true) // filterSetting?.buildPredicate()
        // TODO: Use stored sorting direction and order
        fetch.sortDescriptors = []
        return fetch
    }
    
    public override func awakeFromInsert() {
        if self.filterSetting == nil {
            self.filterSetting = FilterSetting(context: self.managedObjectContext!)
        }
    }
}
