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
                    guard let userInfo = transaction.objectIDNotification().userInfo else {
                        return
                    }
                    let viewContext = self.container.viewContext
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: userInfo, into: [viewContext])
                }
            }

            // MARK: Deduplication
            
            // Pre-filter the changes
            let relevantChanges = transactions
                // Create a flattened array of all changes
                .flatMap { $0.changes ?? [] } // returns [NSPersistentHistoryChange]
                // Only look at inserts
                .filter { $0.changeType == .insert }
            
            // Deduplicate all entities
            for entity in DeduplicationEntity.allCases {
                let entityName = entity.entityName
                
                let changedObjectIDs = relevantChanges
                    // Only consider changes that involve the current entity
                    .filter { $0.changedObjectID.entity.name == entityName }
                    // We only need the objectIDs of the changes
                    .map(\.changedObjectID)
                
                deduplicateAndWait(entity, changedObjectIDs: changedObjectIDs)
            }
            
            // Update the history token using the last transaction.
            lastHistoryToken = transactions.last!.token
        }
    }
}

// MARK: - Deduplicate Medias

extension PersistenceController {
    /// Deduplicate tags with the same name by processing the persistent history, one entity at a time, on the historyQueue.
    ///
    /// All peers should eventually reach the same result with no coordination or communication.
    private func deduplicateAndWait(_ entity: DeduplicationEntity, changedObjectIDs: [NSManagedObjectID]) {
        // Make any store changes on a background context
        let taskContext = container.newBackgroundContext()
        
        // Use performAndWait because each step relies on the sequence.
        // Because historyQueue runs in the background, waiting won’t block the main queue.
        taskContext.performAndWait {
            changedObjectIDs.forEach { objectID in
                deduplicate(entity, changedObjectID: objectID, performingContext: taskContext)
            }
            // Save the background context to trigger a notification and merge the result into the viewContext.
            PersistenceController.saveContext(taskContext)
        }
    }
    
    private func deduplicate(
        _ entity: DeduplicationEntity,
        changedObjectID: NSManagedObjectID,
        performingContext: NSManagedObjectContext
    ) {
        let object = performingContext.object(with: changedObjectID)
        
        /// Cast the object to the generic type and return it on success
        func castObject<T>() -> T {
            guard let object = object as? T else {
                fatalError("###\(#function): Failed to retrieve object for objectID: \(object.objectID)")
            }
            return object
        }
        
        // MARK: Decide how to select the winner
        
        // TODO: Maybe we should do the winner selection in a closure instead of using a KeyPath to support more complex decisions?
        
        switch entity {
        case .media:
            let media: Media = castObject()
            deduplicateObject(
                media,
                entity: entity,
                chosenBy: \Media.modificationDate,
                ascending: false,
                uniquePropertyName: "id",
                uniquePropertyValue: media.id!.uuidString,
                performingContext: performingContext
            )
        case .tag:
            break
        case .genre:
            break
        case .userMediaList:
            break
        case .dynamicMediaList:
            break
        case .filterSetting:
            break
        case .productionCompany:
            break
        case .season:
            break
        case .video:
            break
        }
    }
    
    /// Deduplicates the given object instance using the given winner criteria
    /// - Parameters:
    ///   - object: The `NSManagedObject` instance to deduplicate
    ///   - entity: The `DeduplicationEntity` of the object
    ///   - keyPath: A `KeyPath` describing the property to use for selecting a winner between the duplicates. The duplicates will be sorted by this property.
    ///   - ascending: Whether the duplicates should be sorted by the given keyPath in an ascending order, before choosing the first object as the winner.
    ///   - propertyName: The name of the property to use for detecting duplicates.
    ///   - propertyValue: The value of the property for the given object.
    ///   - performingContext: The `NSManagedObjectContext` in which we are currently performing.
    private func deduplicateObject<T: NSManagedObject, V: CVarArg, U>(
        _ object: T,
        entity: DeduplicationEntity,
        chosenBy keyPath: KeyPath<T, U>,
        ascending: Bool,
        uniquePropertyName propertyName: String,
        uniquePropertyValue propertyValue: V,
        performingContext: NSManagedObjectContext
    ) {
        guard entity.modelType == T.self else {
            // We crash here since it does not make sense to continue. We will crash in the switch statement below anyways
            fatalError("Error: deduplicate() called with mismatching object of type \(T.self) " +
                       "and entity parameter of type \(entity.modelType).")
        }
        
        // Fetch all objects with matching properties, sorted by the given keyPath
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest<T>(entityName: T.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: keyPath, ascending: ascending)]
        fetchRequest.predicate = NSPredicate(format: "%K == %@", propertyName, propertyValue)
        
        // Return if there are no duplicates.
        guard
            var duplicates = try? performingContext.fetch(fetchRequest),
            duplicates.count > 1
        else {
            return
        }
        
        print("###\(#function): Deduplicating objects of type \(T.self) on property " +
              "\(propertyName) = \(propertyValue), count: \(duplicates.count)")
        
        // Pick the first object as the winner
        let winner = duplicates.first!
        duplicates.removeFirst()
        
        // Remove the other candidates (we need to split up into different functions here)
        switch entity {
        case .media:
            remove(
                duplicatedMedias: duplicates as! [Media],
                winner: winner as! Media,
                performingContext: performingContext
            )
        case .tag:
            remove(
                duplicatedTags: duplicates as! [Tag],
                winner: winner as! Tag,
                performingContext: performingContext
            )
        case .genre:
            break
        case .userMediaList:
            break
        case .dynamicMediaList:
            break
        case .filterSetting:
            break
        case .productionCompany:
            break
        case .season:
            break
        case .video:
            break
        }
    }
    
    /// Removes the given duplicate `Media` objects
    /// - Parameters:
    ///   - duplicatedMedias: The list of medias to remove
    ///   - winner: The winner media that can be used as a replacement
    ///   - performingContext: The `NSManagedObjectContext` we are currently performing in
    private func remove(duplicatedMedias: [Media], winner: Media, performingContext: NSManagedObjectContext) {
        duplicatedMedias.forEach { media in
            defer { performingContext.delete(media) }
            
            // TODO: Should we merge other properties? (notes, rating, watched, isFavorite, ...)
            
            print("###\(#function): Removing deduplicated medias")
            exchange(media, with: winner, in: \.medias, on: \.userLists)
            exchange(media, with: winner, in: \.medias, on: \.productionCompanies)
            exchange(media, with: winner, in: \.medias, on: \.genres)
            exchange(media, with: winner, in: \.medias, on: \.tags)
            
            // Media.videos and Show.seasons will be automatically deleted by their cascading deletion rules
            
            if
                let show = media as? Show,
                let winnerShow = winner as? Show
            {
                exchange(show, with: winnerShow, in: \.shows, on: \.networks)
            }
        }
    }
    
    /// Removes the given duplicate `Tag` objects
    /// - Parameters:
    ///   - duplicatedTags: The list of tags to remove
    ///   - winner: The winner tag that can be used as a replacement
    ///   - performingContext: The `NSManagedObjectContext` we are currently performing in
    private func remove(duplicatedTags: [Tag], winner: Tag, performingContext: NSManagedObjectContext) {
        duplicatedTags.forEach { tag in
            defer { performingContext.delete(tag) }
            
            print("###\(#function): Removing deduplicated tags")
            exchange(tag, with: winner, in: \.tags, on: \.medias)
            exchange(tag, with: winner, in: \.tags, on: \.filterSettings)
        }
    }
    
    /// Exchanges the given duplicate instance with the winner instance.
    /// The instance is exchanged in all sets that are located at the `referenceKeyPath` under the `propertyKeyPath`
    ///
    ///     let duplicateTag = Tag(...)
    ///     let winnerTag = Tag(...)
    ///
    ///     // Go through all medias associated with the duplicate tag (\.medias)
    ///     // and replace the duplicate tag in the tags of that media (\.tags)
    ///     exchange(duplicateTag, with: winnerTag, in: \.tags, on: \.medias)
    ///
    ///     // After execution, all medias in duplicateTag.medias contain the winnerTag,
    ///     // instead of the duplicateTag
    ///
    /// - Parameters:
    ///   - duplicate: The duplicate object
    ///   - winner: The winner object
    ///   - referenceKeyPath: A reference to a Set of objects of the same type as duplicate and winner.
    ///   - propertyKeyPath: A reference to a Set of objects of the same type as the root of the `referenceKeyPath`.
    private func exchange<T, V>(
        _ duplicate: T,
        with winner: T,
        in referenceKeyPath: ReferenceWritableKeyPath<V, Set<T>>,
        on propertyKeyPath: KeyPath<T, Set<V>>
    ) {
        // For each item in the given list, remove the duplicate and add the winner
        duplicate[keyPath: propertyKeyPath].forEach { item in
            item[keyPath: referenceKeyPath].remove(duplicate)
            item[keyPath: referenceKeyPath].insert(winner)
        }
    }
}
