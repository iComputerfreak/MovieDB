//
//  Persistence.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData

let appTransactionAuthorName = "app"

class PersistenceController {
    /// The main instance of the PersistenceController
    private(set) static var shared: PersistenceController = .init()
    
    /// The view context of the shared container
    static var viewContext: NSManagedObjectContext { shared.container.viewContext }
    
    /// The view context of the preview container
    static var previewContext: NSManagedObjectContext { preview.container.viewContext }
    
    /// The PersistenceController to be used for previews. May not be used simultaneously with the shared controller
    static var preview: PersistenceController = .init(forTesting: true)
    
    private(set) var container: NSPersistentContainer
    
    // Manages the persistent history
    private let historyManager = HistoryManager()
    
    /// Creates a new `PersistsenceController`
    /// - Parameter forTesting: Configures the controller for testing purposes
    ///
    /// `forTesting` does the following:
    /// * keep the store in memory instead of using the default SQLite database
    /// * disable persistent history tracking
    /// * disable query generations
    private init(forTesting: Bool = false) {
        if forTesting {
            container = NSPersistentContainer(name: "Movie DB")
        } else {
            container = NSPersistentCloudKitContainer(name: "Movie DB")
        }
        let description = container.persistentStoreDescriptions.first
        
        if forTesting {
            description?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // MARK: Store Configuration
        Self.configureStoreDescription(description, forTesting: forTesting)
        
        // MARK: Load store
        container.loadPersistentStores { _, error in
            print("Finished loading persistent stores.")
            if let error = error as NSError? {
                AlertHandler.showError(
                    title: Strings.Alert.errorLoadingCoreDataTitle,
                    error: error
                )
                // TODO: What else could we do, if the store is inaccessible?
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // MARK: Context configuration
        Self.configureViewContext(container.viewContext, forTesting: forTesting)
        
        // MARK: Notification Observers
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: nil,
            using: historyManager.fetchChanges(_:)
        )
        
        // Only initialize the iCloud schema when building the app with the
        // Debug build configuration.
        // Enable once in a while (leaving it enables slows down the app starts)
//        #if DEBUG
//            do {
//                // Use the container to initialize the development schema.
//                let cloudKitContainer = container as? NSPersistentCloudKitContainer
//                try cloudKitContainer?.initializeCloudKitSchema(options: [])
//            } catch {
//                // Handle any errors.
//                // No fatalError() because it will make the app crash if there is no iCloud Account set up
//                print("\(error)")
//            }
//        #endif
    }
    
    static func prepareForUITesting() {
        shared.container = createTestingContainer()
        shared.container.viewContext.type = .viewContext
    }
    
    static func configureStoreDescription(
        _ description: NSPersistentStoreDescription?,
        forTesting: Bool
    ) {
        // Migration settings
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        // Turn on persistent history tracking
        description?.setOption(!forTesting as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        // Turn on remote change notifications
        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
        description?.setOption(true as NSNumber, forKey: remoteChangeKey)
    }
    
    static func configureViewContext(_ viewContext: NSManagedObjectContext, forTesting: Bool) {
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.undoManager = nil
        viewContext.shouldDeleteInaccessibleFaults = true
        viewContext.type = .viewContext
        viewContext.transactionAuthor = appTransactionAuthorName
        
        // Pin the viewContext to the current generation token, and set it to keep itself up to date with local changes.
        viewContext.automaticallyMergesChangesFromParent = true
        if !forTesting {
            do {
                try viewContext.setQueryGenerationFrom(.current)
            } catch {
                fatalError("###\(#function): Failed to pin viewContext to the current generation: \(error)")
            }
        }
    }
    
    func reset() throws {
        // TODO: LibraryList is not refreshing after batch deletes
        // Reset all entities
        let entities = container.managedObjectModel.entities.compactMap(\.name)
        
        for entity in entities {
            let request = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: entity))
            try container.viewContext.execute(request)
        }
        
        saveContext()
    }
}

extension Notification.Name {
    static let didFindRelevantTransactions = Notification.Name("didFindRelevantTransactions")
}
