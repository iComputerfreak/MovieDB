//
//  WatchProvider+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

@objc(WatchProvider)
public class WatchProvider: NSManagedObject {
    convenience init(
        context: NSManagedObjectContext,
        id: Int,
        type: ProviderType,
        name: String,
        imagePath: String?,
        priority: Int
    ) {
        self.init(context: context)
        self.id = id
        self.type = type
        self.name = name
        self.imagePath = imagePath
        self.priority = priority
    }
    
    convenience init(context: NSManagedObjectContext, dummy: WatchProviderDummy, type: WatchProvider.ProviderType) {
        self.init(
            context: context,
            id: dummy.id,
            type: type,
            name: dummy.name,
            imagePath: dummy.imagePath,
            priority: dummy.priority
        )
    }
    
    static func fetchOrCreate(
        _ dummy: WatchProviderDummy,
        type: WatchProvider.ProviderType,
        in context: NSManagedObjectContext
    ) -> WatchProvider {
        let fetchRequest = Self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", Schema.WatchProvider.id.rawValue, dummy.id as NSNumber)
        fetchRequest.fetchLimit = 1
        if let result = try? context.fetch(fetchRequest).first {
            return result
        }
        
        // Create instead
        return WatchProvider(context: context, dummy: dummy, type: type)
    }
}
