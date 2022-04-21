//
//  PlaceholderData.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData

enum PlaceholderData {
    
    static let viewContext = PersistenceController.previewContext
    
    static let allMedia: [Media] = fetchAll()
    static let movie: Movie = fetchFirst()
    static let show: Show = fetchFirst()
    
    static let allTags: [Tag] = fetchAll()
    
    private static func fetchFirst<T: NSManagedObject>() -> T {
        fetchAll().first!
    }
    
    private static func fetchAll<T: NSManagedObject>() -> [T] {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: T.entity().name!)
        // Only used in Previews
        // swiftlint:disable:next force_try
        return try! viewContext.fetch(fetchRequest)
    }
    
}
