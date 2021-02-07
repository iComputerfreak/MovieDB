//
//  TagLibrary+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 07.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TagLibrary)
public class TagLibrary: NSManagedObject {
    
    // We only store a single MediaLibrary in the container, therefore we just use the first result
    static let shared: TagLibrary = TagLibrary.getInstance()
    
    private static func getInstance() -> TagLibrary {
        let results = try? AppDelegate.viewContext.fetch(TagLibrary.fetchRequest())
        if let storedLibrary = results?.first as? TagLibrary {
            return storedLibrary
        }
        // If there is no library stored, we create a new one
        let newLibrary = TagLibrary(context: AppDelegate.viewContext)
        try? AppDelegate.viewContext.save()
        
        return newLibrary
    }
    
    let context: NSManagedObjectContext = AppDelegate.viewContext
    
    /// Returns the name of the tag with the given ID
    /// - Parameter id: The ID of the tag
    /// - Returns: The name of the tag with the given ID
    func name(for id: Int) -> String? {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "id = \(id)")
        let tags = try? context.fetch(request)
        assert((tags?.count ?? 0) <= 1, "There are multiple tags with the same ID in the database.")
        return tags?.first?.name
    }
    
    
    /// Creates a new tag with the given name
    /// - Parameter name: The name of the new tag
    /// - Returns: The ID of the created tag
    @discardableResult func create(name: String) throws -> Int {
        var nextID = TagID.nextID
        // Make sure the ID doesn't exist yet (could be possible after a crash)
        while self.tags.map(\.id).contains(nextID) {
            print("Skipping Tag ID \(nextID), since it already exists.")
            nextID = TagID.nextID
        }
        let newTag = Tag(id: nextID, name: name, context: context)
        self.addToTags(newTag)
        try context.save()
        #if DEBUG
        // Check if there are any duplicate tag IDs
        let ids = self.tags.map(\.id)
        let uniqueIDs = Set(ids)
        if ids.count != uniqueIDs.count {
            assertionFailure("There are duplicate Tag IDs assigned!")
        }
        #endif
        return nextID
    }
    
    /// Renames the tag with the given ID
    /// - Parameters:
    ///   - id: The ID of the tag to rename
    ///   - newName: The new name of the tag
    func rename(id: Int, newName: String) throws {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", id)
        let tags = try context.fetch(request)
        guard !tags.isEmpty else {
            assertionFailure("Trying to rename tag with ID \(id) that does not exist.")
            return
        }
        let tag = tags.first!
        tag.name = newName
        try context.save()
    }
    
    /// Removes the tag with the given ID from the library
    /// - Parameter id: The ID of the tag to remove
    func remove(id: Int) throws {
        guard let tag = tags.first(where: { $0.id == id }) else {
            assertionFailure("Unable to delete tag with ID \(id). Tag does not exist.")
            return
        }
        self.removeFromTags(tag)
        context.delete(tag)
        try context.save()
    }

}

extension Collection where Element == Tag {
    func lexicographicallySorted() -> [Tag] {
        return self.sorted { (tag1, tag2) -> Bool in
            return tag1.name.lexicographicallyPrecedes(tag2.name)
        }
    }
}
