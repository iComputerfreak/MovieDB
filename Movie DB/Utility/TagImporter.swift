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
actor TagImporter {
    
    let logger = BasicLogger()
    
    /// Exports all tags as a newline separated string
    /// - Returns: The exported tags
    static func export(context: NSManagedObjectContext) throws -> String {
        // Fetch all tags from storage
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        let tags = try context.fetch(fetchRequest)
        return tags.map(\.name).joined(separator: "\n")
    }
    
    /// Imports the newline separated tag names and creates new tags, if they don't exist yet
    /// - Parameter tags: The newline separated list of tags
    static func `import`(_ tags: String, into context: NSManagedObjectContext) throws {
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
        PersistenceController.saveContext(context)
    }
    
    class BasicLogger {
        
        // swiftlint:disable:next nesting
        enum LogLevel: String {
            case debug, info, warning, error, critical
        }
        
        private var _log: [String]
        
        var log: String {
            return _log.joined(separator: "\n")
        }
        
        init() {
            self._log = []
        }
        
        func debug(_ message: String) {
            log(message, level: .debug)
        }
        
        func info(_ message: String) {
            log(message, level: .info)
        }
        
        func warn(_ message: String) {
            log(message, level: .warning)
        }
        
        func error(_ message: String) {
            log(message, level: .error)
        }
        
        func critical(_ message: String) {
            log(message, level: .critical)
        }
        
        func log(_ message: String, level: LogLevel) {
            log(contentsOf: [message], level: level)
        }
        
        func log(contentsOf log: [String], level: LogLevel) {
            _log.append(contentsOf: log.map({ "[\(level.rawValue.uppercased())] \($0)" }))
        }
    }
    
}
