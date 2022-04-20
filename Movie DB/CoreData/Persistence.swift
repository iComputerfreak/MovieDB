//
//  Persistence.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData

struct PersistenceController {
    
    let container: NSPersistentCloudKitContainer
    
    private init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Movie DB")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                AlertHandler.showSimpleAlert(title: "Error loading data",
                                             message: "There was an error while loading. \(error)")
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Automatically merge changes done in other context of this container.
        // E.g. merge changes from a background context, as soon as that context saves
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.name = "View Context"
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MediaLibrary.fixDuplicates(notification:)),
                                               name: .NSPersistentStoreRemoteChange,
                                               object: container.viewContext)
    }
    
    // MARK: - Static Properties and Functions
    
    /// The main instance of the PersistenceController
    static let shared = PersistenceController()
    
    /// The view context of the shared container
    static var viewContext: NSManagedObjectContext {
        return shared.container.viewContext
    }
    
    /// The view context of the preview container
    static var previewContext: NSManagedObjectContext {
        return preview.container.viewContext
    }
    
    /// The PersistenceController to be used for previews. May not be used simultaneously with the shared controller
    static var preview: PersistenceController = {
        return PersistenceController(inMemory: true)
    }()
    
    /// Creates a new background context without a parent
    /// - Returns: A background context that saves directly to the container
    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }
    
    /// Creates and returns a new `NSManagedObjectContext` that can be used for creating temporary data (e.g., Seasons that are part of a `SearchResult`)
    /// A context created by this method may not be saved!
    static func createDisposableContext() -> NSManagedObjectContext {
        // The disposable context is a new empty context without any data in it
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.name = "Disposable Context (\(Date()))"
        return context
    }
    
    /// Creates a new context with a new, empty container behind it to be used for testing
    /// - Returns: A context of a newly created, empty container
    static func createTestingContext() -> NSManagedObjectContext {
        shared.createTestingContext()
    }
    
    /// Creates a new context with a new, empty container behind it to be used for testing
    /// - Returns: A context of a newly created, empty container
    func createTestingContext() -> NSManagedObjectContext {
        // We need to reuse the same model as in the view context (so there are no duplicate models at the same time)
        let container = NSPersistentContainer(name: "Movie DB", managedObjectModel: self.container.managedObjectModel)
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
        container.viewContext.name = "Testing View Context"
        return container.viewContext
    }
    
    // MARK: Saving
    
    /// Saves the shared viewContext
    func saveContext() {
        Task {
            print("========================")
            print("SAVING CORE DATA CONTEXT")
            print("========================")
            await PersistenceController.saveContext(container.viewContext)
        }
    }
    
    /// Saves the shared viewContext
    static func saveContext(file: String = #file, line: Int = #line) {
        print("Saving shared viewContext from \(file):\(line)")
        shared.saveContext()
    }
    
    /// Saves the given context if it has been modified since the last save
    /// Performs the save operation synchronous and returns when it was completed.
    /// - Parameter context: The `NSManagedObjectContext` to save
    @available(*, deprecated, renamed: "saveContext(_:file:line:)")
    static func saveContext(_ context: NSManagedObjectContext, file: String = #file, line: Int = #line) {
        print("Trying to save context \(context.description) from \(file):\(line). " +
              "Parent: \(context.parent?.description ?? "nil")")
        // Make sure we save on the correct thread to prevent race conditions
        // See: https://developer.apple.com/forums/thread/668299
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    AlertHandler.showSimpleAlert(title: "Error saving data",
                                                 message: "There was an error while saving. " +
                                                 "\(nserror), \(nserror.userInfo)")
//                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            } else {
                print("Context has no changes.")
            }
        }
    }
    
    /// Saves the given context if it has been modified since the last save
    /// Performs the save operation asynchronous
    /// - Parameter context: The `NSManagedObjectContext` to save
    static func saveContext(_ context: NSManagedObjectContext, file: String = #file, line: Int = #line) async {
        print("Trying to save context \(context.description) from \(file):\(line). " +
              "Parent: \(context.parent?.description ?? "nil")")
        // Make sure we save on the correct thread to prevent race conditions
        // See: https://developer.apple.com/forums/thread/668299
        await context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    AlertHandler.showSimpleAlert(title: "Error saving data",
                                                 message: "There was an error while saving. " +
                                                 "\(nserror), \(nserror.userInfo)")
//                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            } else {
                print("Context has no changes.")
            }
        }
    }
}
