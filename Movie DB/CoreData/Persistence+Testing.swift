//
//  Persistence+Testing.swift
//  Movie DB
//
//  Created by Jonas Frey on 20.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

extension PersistenceController {
    /// Creates a new, empty container to be used for testing
    /// - Returns: A newly created, empty container
    func createTestingContainer() -> NSPersistentContainer {
        // We need to reuse the same model as in the view context (so there are no duplicate models at the same time)
        let container = NSPersistentContainer(name: "Movie DB", managedObjectModel: container.managedObjectModel)
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unexpected Error \(error)")
            }
        }
        // Automatically merge changes done in other context of this container.
        // E.g. merge changes from a background context, as soon as that context saves
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.type = .viewContext
        container.viewContext.transactionAuthor = appTransactionAuthorName
        return container
    }
    
    /// Creates a new context with a new, empty container behind it to be used for testing
    /// - Returns: A context of a newly created, empty container
    static func createTestingContext() -> NSManagedObjectContext {
        createTestingContainer().viewContext
    }
    
    /// Creates a new context with a new, empty container behind it to be used for testing
    /// - Returns: A context of a newly created, empty container
    static func createTestingContainer() -> NSPersistentContainer {
        shared.createTestingContainer()
    }
}
