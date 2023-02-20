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
    static var preview: PersistenceController = .init(inMemory: true)
    
    private(set) var container: NSPersistentContainer
    
    private init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Movie DB")
        let description = container.persistentStoreDescriptions.first
        
        if inMemory {
            description?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // MARK: Store Configuration
        Self.configureStoreDescription(description)
        
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
        Self.configureViewContext(container.viewContext)
        
        // MARK: Notification Observers
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: nil,
            using: fetchChanges(_:)
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
    
    static func configureStoreDescription(_ description: NSPersistentStoreDescription?) {
        // Migration settings
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = false
        // Turn on persistent history tracking
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        // Turn on remote change notifications
        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
        description?.setOption(true as NSNumber, forKey: remoteChangeKey)
    }
    
    static func configureViewContext(_ viewContext: NSManagedObjectContext) {
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.undoManager = nil
        viewContext.shouldDeleteInaccessibleFaults = true
        viewContext.type = .viewContext
        viewContext.transactionAuthor = appTransactionAuthorName
        
        // Pin the viewContext to the current generation token, and set it to keep itself up to date with local changes.
        viewContext.automaticallyMergesChangesFromParent = true
        do {
            try viewContext.setQueryGenerationFrom(.current)
        } catch {
            fatalError("###\(#function): Failed to pin viewContext to the current generation: \(error)")
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
    
    // MARK: Persistent History Tracking
    
    /// Track the last history token processed for a store, and write its value to file.
    ///
    /// The `historyQueue` reads the token when executing operations and updates it after processing is complete.
    private var lastHistoryToken: NSPersistentHistoryToken? = nil {
        didSet {
            guard
                let token = lastHistoryToken,
                let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
            else {
                return
            }
            
            do {
                try data.write(to: tokenFile)
            } catch {
                print("###\(#function): Failed to write token data. Error: \(error)")
            }
        }
    }
    
    /// The file URL for persisting the persistent history token.
    private lazy var tokenFile: URL = {
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("MovieDB", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("###\(#function): Failed to create persistent container URL. Error: \(error)")
            }
        }
        return url.appendingPathComponent("token.data", isDirectory: false)
    }()
    
    /// An operation queue for handling history processing tasks: watching changes, deduplicating tags, and triggering UI updates if needed.
    private lazy var historyQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

extension Notification.Name {
    static let didFindRelevantTransactions = Notification.Name("didFindRelevantTransactions")
}

// MARK: - Persistent History Tracking

extension PersistenceController {
    /// Handle remote store change notifications (.NSPersistentStoreRemoteChange).
    func fetchChanges(_ notification: Notification) {
        // Process persistent history to merge changes from other coordinators.
        historyQueue.addOperation {
            self.processPersistentHistory()
        }
    }
    
    /// Process persistent history, posting any relevant transactions to the current view.
    func processPersistentHistory() {
        let taskContext = container.newBackgroundContext()
        taskContext.performAndWait {
            // Fetch history received from outside the app since the last token
            let historyFetchRequest = NSPersistentHistoryTransaction.fetchRequest!
            historyFetchRequest.predicate = NSPredicate(format: "author != %@", appTransactionAuthorName)
            let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
            request.fetchRequest = historyFetchRequest

            let result = (try? taskContext.execute(request)) as? NSPersistentHistoryResult
            guard
                let transactions = result?.result as? [NSPersistentHistoryTransaction],
                !transactions.isEmpty
            else { return }

            // Post transactions relevant to the current view.
            DispatchQueue.main.async {
                // TODO: Receive these notification in the views and update (look up how to do with SwiftUI)
                NotificationCenter.default.post(
                    name: .didFindRelevantTransactions,
                    object: self,
                    userInfo: ["transactions": transactions]
                )
                
                // !!!: Alternatively: (update on any change, like we did before)
                transactions.forEach { transaction in
                    guard let userInfo = transaction.objectIDNotification().userInfo else { return }
                    let viewContext = self.container.viewContext
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: userInfo, into: [viewContext])
                }
            }

            // Deduplicate the new tags.
            var newMediaObjectIDs = [NSManagedObjectID]()
            let mediaEntityName = Media.entity().name

            for transaction in transactions where transaction.changes != nil {
                for change in transaction.changes!
                    where change.changedObjectID.entity.name == mediaEntityName && change.changeType == .insert {
                        newMediaObjectIDs.append(change.changedObjectID)
                }
            }
            
            if !newMediaObjectIDs.isEmpty {
                deduplicateAndWait(mediaObjectIDs: newMediaObjectIDs)
            }
            
            // Update the history token using the last transaction.
            lastHistoryToken = transactions.last!.token
        }
    }
}

// MARK: - Deduplicate Medias

// TODO: Do with other entities as well

extension PersistenceController {
    /// Deduplicate tags with the same name by processing the persistent history, one tag at a time, on the historyQueue.
    ///
    /// All peers should eventually reach the same result with no coordination or communication.
    private func deduplicateAndWait(mediaObjectIDs: [NSManagedObjectID]) {
        // Make any store changes on a background context
        let taskContext = container.newBackgroundContext()
        
        // Use performAndWait because each step relies on the sequence.
        // Because historyQueue runs in the background, waiting won’t block the main queue.
        taskContext.performAndWait {
            mediaObjectIDs.forEach { mediaObjectID in
                deduplicate(mediaObjectID: mediaObjectID, performingContext: taskContext)
            }
            // Save the background context to trigger a notification and merge the result into the viewContext.
            PersistenceController.saveContext(taskContext)
        }
    }

    /// Deduplicate a single tag.
    private func deduplicate(mediaObjectID: NSManagedObjectID, performingContext: NSManagedObjectContext) {
        guard
            let media = performingContext.object(with: mediaObjectID) as? Media,
            let mediaID = media.id
        else {
            // TODO: Replace with correct error handling
            fatalError("###\(#function): Failed to retrieve a valid media with objectID: \(mediaObjectID)")
        }

        // Fetch all medias with the same id, sorted by modificationDate
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Media.modificationDate, ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "id == %@", mediaID.uuidString)
        
        // Return if there are no duplicates.
        guard
            var duplicatedMedias = try? performingContext.fetch(fetchRequest),
            duplicatedMedias.count > 1
        else { return }
        print("###\(#function): Deduplicating media with title: \(media.title), count: \(duplicatedMedias.count)")
        
        // Pick the first media as the winner (latest modification date)
        let winner = duplicatedMedias.first!
        duplicatedMedias.removeFirst()
        remove(duplicatedMedias: duplicatedMedias, winner: winner, performingContext: performingContext)
    }
    
    /// Remove duplicate tags from their respective posts, replacing them with the winner.
    private func remove(duplicatedMedias: [Media], winner: Media, performingContext: NSManagedObjectContext) {
        duplicatedMedias.forEach { media in
            defer { performingContext.delete(media) }
            
            // TODO: What to do here?
            // - copy over custom lists, isFavorite, isBookmarked?
            // - copy over other user data?
            print("###\(#function): Removing deduplicated medias")
        }
    }
}
