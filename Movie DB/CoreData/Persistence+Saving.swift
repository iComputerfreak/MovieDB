//
//  Persistence+Saving.swift
//  Movie DB
//
//  Created by Jonas Frey on 20.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

extension PersistenceController {
    /// Saves the shared viewContext
    func saveContext() {
        Task {
            print("========================")
            print("SAVING CORE DATA CONTEXT")
            print("========================")
            await Self.saveContext(container.viewContext)
        }
    }
    
    /// Saves the shared viewContext
    static func saveContext(file: String = #file, line: Int = #line) {
        print("Saving shared viewContext from \(file):\(line)")
        shared.saveContext()
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
            print("Starting save...")
            if context.hasChanges {
                do {
                    try context.save()
                    print("Context saved.")
                } catch {
                    let nserror = error as NSError
                    print(nserror)
                    AlertHandler.showError(
                        title: Strings.Alert.errorSavingCoreDataTitle,
                        error: nserror
                    )
                }
            } else {
                print("Context has no changes.")
            }
        }
    }
    
    /// Saves the given context if it has been modified since the last save
    /// Performs the save operation synchronous and returns when it was completed.
    /// - Parameter context: The `NSManagedObjectContext` to save
    static func saveContext(_ context: NSManagedObjectContext, file: String = #file, line: Int = #line) {
        print("Trying to save context \(context.description) from \(file):\(line). " +
            "Parent: \(context.parent?.description ?? "nil")")
        // Make sure we save on the correct thread to prevent race conditions
        // See: https://developer.apple.com/forums/thread/668299
        context.performAndWait {
            print("Starting save...")
            if context.hasChanges {
                do {
                    try context.save()
                    print("Context saved.")
                } catch {
                    print(error)
                    AlertHandler.showError(
                        title: Strings.Alert.errorSavingCoreDataTitle,
                        error: error
                    )
                }
            } else {
                print("Context has no changes.")
            }
        }
    }
}
