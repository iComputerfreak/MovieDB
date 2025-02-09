//
//  Persistence.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData
import os.log

let appTransactionAuthorName = "app"

class PersistenceController {
    /// The main instance of the PersistenceController
    private(set) static var shared: PersistenceController = .init()
    
    /// The view context of the shared container
    static var viewContext: NSManagedObjectContext { shared.container.viewContext }
    
    /// The view context of the preview container
    static var xcodePreviewContext: NSManagedObjectContext { preview.container.viewContext }
    
    /// The PersistenceController to be used for previews. May not be used simultaneously with the shared controller
    static var preview: PersistenceController = .init(forTesting: true, usePersistentHistory: false)
    
    private(set) var container: NSPersistentContainer
    
    // Manages the persistent history
    private let historyManager = HistoryManager()
    
    // The observer used for monitoring remote store changes
    private static var remoteChangeObserver: NSObjectProtocol?
    
    // The Core Data model in use
    private static var model: NSManagedObjectModel?
    
    /// Creates a new `PersistsenceController`
    /// - Parameter forTesting: Configures the controller for testing purposes
    ///
    /// `forTesting` does the following:
    /// * keep the store in memory instead of using the default SQLite database
    /// * disable iCloud sync
    ///
    /// `usePersistentHistory` does the following:
    /// * enable persistent history tracking
    /// * enable query generations
    private init(forTesting: Bool = false, usePersistentHistory: Bool = true) {
        // swiftlint:disable:previous function_body_length
        if !Thread.isMainThread {
            Logger.lifeCycle.error("Creating PersistenceController on a background thread. This may cause a deadlock.")
            assertionFailure()
        }
        // If we already have an existing model, reuse it
        if let model = Self.model {
            // Use the existing model
            if forTesting {
                container = NSPersistentContainer(name: "Movie DB", managedObjectModel: model)
            } else {
                container = NSPersistentCloudKitContainer(name: "Movie DB", managedObjectModel: model)
            }
        } else {
            // Create a new model
            if forTesting {
                container = NSPersistentContainer(name: "Movie DB")
            } else {
                container = NSPersistentCloudKitContainer(name: "Movie DB")
            }
            Self.model = container.managedObjectModel
        }
        
        let description = container.persistentStoreDescriptions.first
        
        if forTesting {
            description?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // MARK: Store Configuration
        Self.configureStoreDescription(description, forTesting: forTesting, usePersistentHistory: usePersistentHistory)
        
        // MARK: Load store
        container.loadPersistentStores { _, error in
            Logger.coreData.info("Finished loading persistent stores.")
            if let error = error as NSError? {
                AlertHandler.showError(
                    title: Strings.Alert.errorLoadingCoreDataTitle,
                    error: error
                )
                Logger.coreData.critical("Error loading persistent store: \(error)")
                // If there was an error loading the persistent store, there is no data to display and we have to crash the app
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Only initialize the iCloud schema when building the app with the
        // Debug build configuration.
        #if DEBUG
            let lastInitKey = "lastICloudSchemaInitialization"
            let lastInitSeconds = UserDefaults.standard.double(forKey: lastInitKey)
            let lastInit = Date(timeIntervalSince1970: lastInitSeconds)
            // Only initialize, if the last init was longer than an hour ago
            if (abs(lastInitSeconds) < 0.001) || lastInit.distance(to: .now) < 12 * 3600 {
                do {
                    Logger.coreData.info("Initializing CloudKit schema...")
                    // Use the container to initialize the development schema.
                    let cloudKitContainer = container as? NSPersistentCloudKitContainer
                    try cloudKitContainer?.initializeCloudKitSchema()
                    UserDefaults.standard.set(Date.now.timeIntervalSince1970, forKey: lastInitKey)
                } catch {
                    // Handle any errors.
                    // No fatalError() because it will make the app crash if there is no iCloud Account set up
                    Logger.coreData.fault("Error initializing iCloud schema: \(error, privacy: .public)")
                }
            }
        #endif
        
        // MARK: Context configuration
        Self.configureViewContext(
            container.viewContext,
            forTesting: forTesting,
            usePersistentHistory: usePersistentHistory
        )
        
        // MARK: Notification Observers
        // Only create observer if there isn't one already
        if !forTesting, Self.remoteChangeObserver == nil {
            Self.remoteChangeObserver = NotificationCenter.default.addObserver(
                forName: .NSPersistentStoreRemoteChange,
                object: container.persistentStoreCoordinator,
                queue: nil,
                using: historyManager.fetchChanges(_:)
            )
        }
    }
    
    static func prepareForUITesting() {
        // Disable remote store notifications, as we will replace the shared controller with one that does not support them
        if let remoteChangeObserver {
            NotificationCenter.default.removeObserver(remoteChangeObserver)
        }
        shared = PersistenceController(forTesting: true, usePersistentHistory: false)
    }
    
    static func configureStoreDescription(
        _ description: NSPersistentStoreDescription?,
        forTesting: Bool,
        usePersistentHistory: Bool
    ) {
        // Migration settings
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        if usePersistentHistory {
            // Turn on persistent history tracking
            description?.setOption(!forTesting as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            // Turn on remote change notifications
            let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
            description?.setOption(true as NSNumber, forKey: remoteChangeKey)
        }
    }
    
    static func configureViewContext(
        _ viewContext: NSManagedObjectContext,
        forTesting: Bool,
        usePersistentHistory: Bool
    ) {
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.undoManager = nil
        viewContext.shouldDeleteInaccessibleFaults = true
        viewContext.type = .viewContext
        viewContext.transactionAuthor = appTransactionAuthorName
        
        // Pin the viewContext to the current generation token, and set it to keep itself up to date with local changes.
        viewContext.automaticallyMergesChangesFromParent = true
        if usePersistentHistory {
            do {
                try viewContext.setQueryGenerationFrom(.current)
            } catch {
                fatalError("###\(#function): Failed to pin viewContext to the current generation: \(error)")
            }
        }
    }
    
    func reset() throws {
        // Get a list of all Core Data entities
        let entities = container.managedObjectModel.entities.compactMap(\.name)
        
        // Save pending changes
        saveContext()
        
        // Delete all entities
        for entity in entities {
            let request = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: entity))
            try container.viewContext.executeAndMergeChanges(using: request)
        }
        
        // TODO: For some reason, the tags don't get deleted by the NSBatchDeleteRequest, so we have to do it manually
        let tags = (try? container.viewContext.fetch(Tag.fetchRequest())) ?? []
        for tag in tags {
            container.viewContext.delete(tag)
        }
        
        saveContext()
    }
}

extension Notification.Name {
    static let didFindRelevantTransactions = Notification.Name("didFindRelevantTransactions")
}
