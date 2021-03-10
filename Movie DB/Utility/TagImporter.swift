//
//  TagImporter.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData

/// Represents a utility struct that ex- or imports tags from and to the TagLibrary
struct TagImporter {
    
    /// Exports all tags as a newline separated string
    /// - Returns: The exported tags
    static func export(context: NSManagedObjectContext) throws -> String {
        // Fetch all tags from storage
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let tags = try context.fetch(fetchRequest)
        return tags.map(\.name).joined(separator: "\n")
    }
    
    /// Imports the newline separated tag names and creates new tags, if they don't exist yet
    /// - Parameter tags: The newline separated list of tags
    static func `import`(_ tags: String, context: NSManagedObjectContext) throws {
        // Fetch all existing tags from storage
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let fetchedTags = try context.fetch(fetchRequest)
        for name in tags.components(separatedBy: .newlines) {
            if name.isEmpty {
                continue
            }
            // Create all tags, that don't already exist (this includes duplicate lines in the import string)
            if !fetchedTags.contains(where: { $0.name == name }) {
                // Create the tag in the context
                _ = Tag(name: name, context: context)
            }
        }
        try context.save()
    }
    
}
