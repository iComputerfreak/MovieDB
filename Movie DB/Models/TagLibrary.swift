//
//  Tag.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

class TagLibrary: ObservableObject {
    
    // Tag ID Creation
    /// Contains the next free collection id
    private static var _nextID = -1
    /// Returns the next free tag id
    static var nextID: Int {
        // Initialize
        if _nextID < 0 {
            _nextID = UserDefaults.standard.integer(forKey: "nextID")
        }
        // Increase _nextID after returning
        defer {
            _nextID += 1
            UserDefaults.standard.set(_nextID, forKey: "nextID")
        }
        return _nextID
    }
    
    static let shared = TagLibrary()
    
    @Published private(set) var tags: [Tag] = {
        // Load using plist
        if let data = UserDefaults.standard.data(forKey: JFLiterals.Keys.allTags) {
            let loadedValue = try? PropertyListDecoder().decode([Tag].self, from: data)
            if loadedValue != nil {
                return loadedValue!
            }
        }
        return []
    }()
    
    private init() {}
    
    private func save() {
        do {
            let plist = try PropertyListEncoder().encode(self.tags)
            UserDefaults.standard.set(plist, forKey: JFLiterals.Keys.allTags)
        } catch let error {
            print("Error saving tags: \(error)")
        }
    }
    
    /// Returns the name of the tag with the given ID
    /// - Parameter id: The ID of the tag
    /// - Returns: The name of the tag with the given ID
    func name(for id: Int) -> String? {
        return tags.first(where: { $0.id == id })?.name
    }
    
    
    /// Creates a new tag with the given name
    /// - Parameter name: The name of the new tag
    /// - Returns: The ID of the created tag
    @discardableResult func create(name: String) -> Int {
        var nextID = TagLibrary.nextID
        // Make sure the ID doesn't exist yet (could be possible after a crash)
        while self.tags.map(\.id).contains(nextID) {
            print("Skipping Tag ID \(nextID), since it already exists.")
            nextID = TagLibrary.nextID
        }
        self.tags.append(Tag(id: nextID, name))
        save()
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
    func rename(id: Int, newName: String) {
        guard let index = self.tags.firstIndex(where: { $0.id == id }) else {
            return
        }
        self.tags[index].name = newName
        self.objectWillChange.send()
        save()
    }
    
    /// Removes the tag with the given ID from the library
    /// - Parameter id: The ID of the tag to remove
    func remove(id: Int) {
        self.tags.removeAll(where: { $0.id == id })
        save()
    }
}

/// Represents a user specified tag
struct Tag: Codable, Identifiable, Hashable, Equatable {
    /// The ID of the tag
    let id: Int
    /// The name of the tag
    var name: String
    
    /// Creates a new `Tag` with the given ID and name
    /// - Parameters:
    ///   - id: The ID of the tag
    ///   - name: The name of the tag
    fileprivate init(id: Int, _ name: String) {
        self.id = id
        self.name = name
    }
}

extension Collection where Element == Tag {
    func lexicographicallySorted() -> [Tag] {
        return self.sorted { (tag1, tag2) -> Bool in
            return tag1.name.lexicographicallyPrecedes(tag2.name)
        }
    }
}
