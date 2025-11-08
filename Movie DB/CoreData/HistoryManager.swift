//
//  HistoryManager.swift
//  Movie DB
//
//  Created by Jonas Frey on 21.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import os.log

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
                Logger.coreData.warning("Error writing token data: \(error, privacy: .public)")
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
                Logger.coreData.error(
                    "Failed to create persistent container URL to store token file: \(error, privacy: .public)"
                )
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
    
    init() {
        // Load the last token from the token file.
        if let tokenData = try? Data(contentsOf: tokenFile) {
            do {
                lastHistoryToken = try NSKeyedUnarchiver.unarchivedObject(
                    ofClass: NSPersistentHistoryToken.self,
                    from: tokenData
                )
            } catch {
                Logger.coreData.error("Failed to unarchive NSPersistentHistoryToken: \(error, privacy: .public)")
            }
        }
    }
    
    /// Handle remote store change notifications (.NSPersistentStoreRemoteChange).
    func fetchChanges(_ notification: Notification) {
        // Process persistent history to merge changes from other coordinators.
        historyQueue.addOperation {
            print("Processing persistent history")
            self.processPersistentHistory()
        }
    }
    
    /// Process persistent history, posting any relevant transactions to the current view.
    func processPersistentHistory() {
        let taskContext = PersistenceController.shared.newBackgroundContext()
        taskContext.performAndWait {
            // Fetch history received from outside the app since the last token
            guard let historyFetchRequest = NSPersistentHistoryTransaction.fetchRequest else {
                Logger.coreData.warning("Unable to create NSPersistentHistory fetch request.")
                return
            }
            historyFetchRequest.predicate = NSPredicate(format: "author != %@", appTransactionAuthorName)
            let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
            request.fetchRequest = historyFetchRequest

            let result = (try? taskContext.execute(request)) as? NSPersistentHistoryResult
            guard
                let transactions = result?.result as? [NSPersistentHistoryTransaction],
                !transactions.isEmpty
            else {
                Logger.coreData.info("Persistent history result has no transactions.")
                return
            }

            // Post transactions relevant to the current view.
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .didFindRelevantTransactions,
                    object: self,
                    userInfo: ["transactions": transactions]
                )
                
                for transaction in transactions {
                    guard let userInfo = transaction.objectIDNotification().userInfo else {
                        assertionFailure("Unable to get userInfo for remote change transaction")
                        return
                    }
                    
                    #if DEBUG
                    Logger.coreData.debug("\(transaction.description(in: taskContext))")
                    #endif
                    
                    let viewContext = PersistenceController.viewContext
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: userInfo, into: [viewContext])
                }
            }

            // MARK: Deduplication
            
            // Create a flattened array of all changes
            let relevantChanges = transactions
                .flatMap { $0.changes ?? [] }

            let changedObjectIDsByEntity: [DeduplicationEntity?: [NSManagedObjectID]] = Dictionary(
                grouping: relevantChanges,
                by: { change in DeduplicationEntity(entityName: change.changedObjectID.entity.name ?? "") }
            )
                .mapValues { $0.map(\.changedObjectID) }

            // Deduplicate all entities
            for (entity, changedObjectIDs) in changedObjectIDsByEntity {
                guard
                    // We only process entities we know
                    let entity,
                    // No need to call the deduplicator if we have no objects of this entity type
                    !changedObjectIDs.isEmpty
                else { continue }

                // We are still in a background context
                print("Processing deduplication")
                deduplicator.deduplicateAndWait(entity, changedObjectIDs: changedObjectIDs)
            }
            
            // Update the history token using the last transaction.
            Logger.coreData.debug("Updating history token.")
            lastHistoryToken = transactions.last!.token
        }
    }
}
