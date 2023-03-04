//
//  Persistence+Convenience.swift
//  Movie DB
//
//  Created by Jonas Frey on 20.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

extension PersistenceController {
    /// Creates a new background context without a parent
    /// - Returns: A background context that saves directly to the container
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.type = .backgroundContext
        return context
    }
    
    /// Creates a new context with a new, empty container behind it to be used for testing
    /// - Returns: A context of a newly created, empty container
    func createTestingContext() -> NSManagedObjectContext {
        createTestingContainer().viewContext
    }
    
    /// Creates and returns a new `NSManagedObjectContext` that can be used for creating temporary data (e.g., Seasons that are part of a `SearchResult`)
    /// A context created by this method may not be saved!
    static func createDisposableContext() -> NSManagedObjectContext {
        // The disposable context is a new empty context without any data in it
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        let model = shared.container.persistentStoreCoordinator.managedObjectModel
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        context.type = .disposableContext
        context.transactionAuthor = appTransactionAuthorName
        return context
    }
    
    static func createDisposableViewContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let model = shared.container.persistentStoreCoordinator.managedObjectModel
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        context.type = .disposableContext
        context.transactionAuthor = appTransactionAuthorName
        return context
    }
}
