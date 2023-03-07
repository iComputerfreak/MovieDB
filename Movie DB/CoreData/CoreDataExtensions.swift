//
//  CoreDataExtensions.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
    static let mediaType = CodingUserInfoKey(rawValue: "mediaType")!
}

extension NSPersistentHistoryTransaction {
    func description(in context: NSManagedObjectContext) -> String {
        var output: [String] = []
        
        if let changes = self.changes {
            output.append("Merging \(changes.count) changes...")
            for change in changes {
                let object = context.object(with: change.changedObjectID)
                output.append("  \(String(describing: change.changeType)): \(object)")
                if let updatedProperties = change.updatedProperties?.map(\.name) {
                    output.append("    \(updatedProperties.joined(separator: ", "))")
                }
            }
        }
        
        return output.joined(separator: "\n")
    }
}

extension NSPersistentHistoryChangeType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insert:
            return "Insert"
        case .update:
            return "Update"
        case .delete:
            return "Delete"
        default:
            return "Unknown"
        }
    }
}

extension NSManagedObjectContext {
    /// Executes the given `NSBatchDeleteRequest` and directly merges the changes to bring the given managed object context up to date.
    ///
    /// - Parameter batchDeleteRequest: The `NSBatchDeleteRequest` to execute.
    /// - Throws: An error if anything went wrong executing the batch deletion.
    func executeAndMergeChanges(using batchDeleteRequest: NSBatchDeleteRequest) throws {
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}
