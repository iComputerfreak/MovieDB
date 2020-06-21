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
        let plist = try? PropertyListEncoder().encode(self.tags)
        UserDefaults.standard.set(plist, forKey: JFLiterals.Keys.allTags)
    }
    
    func name(for id: Int) -> String? {
        return tags.first(where: { $0.id == id })?.name
    }
    
    // Creates a new tag and adds it to the library
    func create(name: String) {
        var nextID = TagLibrary.nextID
        // Make sure the ID doesn't exist yet (could be possible after a crash)
        while self.tags.map({ $0.id }).contains(nextID) {
            print("Skipping Tag ID \(nextID), since it already exists.")
            nextID = TagLibrary.nextID
        }
        self.tags.append(Tag(id: TagLibrary.nextID, name))
        save()
        #if DEBUG
        // Check if there are any duplicate tag IDs
        let ids = self.tags.map({ $0.id })
        let uniqueIDs = Set(ids)
        if ids.count != uniqueIDs.count {
            assertionFailure("There are duplicate Tag IDs assigned!")
        }
        #endif
    }
    
    func rename(id: Int, newName: String) {
        guard let index = self.tags.firstIndex(where: { $0.id == id }) else {
            return
        }
        self.tags[index].name = newName
        self.objectWillChange.send()
        save()
    }
    
    func remove(id: Int) {
        self.tags.removeAll(where: { $0.id == id })
        save()
    }
}

struct Tag: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    var name: String
    
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
