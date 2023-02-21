//
//  HistoryManager.swift
//  Movie DB
//
//  Created by Jonas Frey on 21.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

class HistoryManager {
    let deduplicator = Deduplicator()
    
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
    
    /// Handle remote store change notifications (.NSPersistentStoreRemoteChange).
    func fetchChanges(_ notification: Notification) {
        // Process persistent history to merge changes from other coordinators.
        historyQueue.addOperation {
            self.processPersistentHistory()
        }
    }
    
    /// Process persistent history, posting any relevant transactions to the current view.
    func processPersistentHistory() {
        let taskContext = PersistenceController.shared.newBackgroundContext()
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
            else {
                return
            }

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
                    let viewContext = PersistenceController.viewContext
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
                
                // We are still in a background context
                deduplicator.deduplicateAndWait(entity, changedObjectIDs: changedObjectIDs)
            }
            
            // Update the history token using the last transaction.
            lastHistoryToken = transactions.last!.token
        }
    }
}
