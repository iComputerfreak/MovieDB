//
//  TagImporter.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

/// Represents a utility struct that ex- or imports tags from and to the TagLibrary
struct TagImporter {
    
    /// Exports all tags as a newline separated string
    /// - Returns: The exported tags
    static func export() -> String {
        return TagLibrary.shared.tags.map(\.name).joined(separator: "\n")
    }
    
    /// Imports the newline separated tag names and creates new tags, if they don't exist yet
    /// - Parameter tags: The newline separated list of tags
    static func `import`(_ tags: String) {
        for name in tags.components(separatedBy: .newlines) {
            if name.isEmpty {
                continue
            }
            // Create all tags, that don't already exist (this includes duplicate lines in the import string)
            if !TagLibrary.shared.tags.contains(where: { $0.name == name }) {
                TagLibrary.shared.create(name: name)
            }
        }
        
    }
    
}
