//
//  Persistence+Saving.swift
//  Movie DB
//
//  Created by Jonas Frey on 20.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import os.log

extension PersistenceController {
    /// Saves the shared viewContext
    func saveContext() {
        Task {
            await Self.saveContext(container.viewContext)
        }
    }
    
    /// Saves the shared viewContext
    static func saveContext(file: String = #file, line: Int = #line) {
        Logger.coreData.trace("Saving Core Data view context \(file):\(line)")
        shared.saveContext()
    }
    
    /// Saves the given context if it has been modified since the last save
    /// Performs the save operation asynchronous
    /// - Parameter context: The `NSManagedObjectContext` to save
    static func saveContext(_ context: NSManagedObjectContext, file: String = #file, line: Int = #line) async {
        Logger.coreData.trace(
            "Saving Core Data context from \(file):\(line). Parent: \(context.parent?.description ?? "nil")"
        )
        Logger.coreData.info("Saving Core Data context with name: \(context.name ?? "unknown")")
        // Make sure we save on the correct thread to prevent race conditions
        // See: https://developer.apple.com/forums/thread/668299
        await context.perform {
            Self.saveContexAndWait(context)
        }
    }
    
    /// Saves the given context if it has been modified since the last save
    /// Performs the save operation synchronous and returns when it was completed.
    /// - Parameter context: The `NSManagedObjectContext` to save
    static func saveContext(_ context: NSManagedObjectContext, file: String = #file, line: Int = #line) {
        Logger.coreData.trace(
            "Saving Core Data context from \(file):\(line). Parent: \(context.parent?.description ?? "nil")"
        )
        Logger.coreData.info("Saving Core Data context with name: \(context.name ?? "unknown")")
        // Make sure we save on the correct thread to prevent race conditions
        // See: https://developer.apple.com/forums/thread/668299
        context.performAndWait {
            Self.saveContexAndWait(context)
        }
    }
    
    
    /// Saves the given context and waits for the saving operation to finish.
    ///
    /// This function does not switch threads and assumes it is already executed on the `context`'s thread
    /// - Parameter context: The context to save
    private static func saveContexAndWait(_ context: NSManagedObjectContext) {
        Logger.coreData.trace("Starting Core Data save...")
        if context.hasChanges {
            do {
                try context.save()
                Logger.coreData.trace("Core Data context saved.")
            } catch {
                Logger.coreData.error("Error saving Core Data context: \(error)")
                AlertHandler.showError(
                    title: Strings.Alert.errorSavingCoreDataTitle,
                    error: error
                )
            }
        } else {
            Logger.coreData.debug("Context has no changes.")
        }
    }
}
