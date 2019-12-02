//
//  Tag.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

class TagLibrary: ObservableObject {
    
    static let shared = TagLibrary()
    
    @Published private(set) var tags: [Tag] = JFConfig.shared.tags
    
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
        self.tags.append(Tag(id: self.tags.count, name))
        save()
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
    }
    
    func remove(atOffsets indexSet: IndexSet) {
        self.tags.remove(atOffsets: indexSet)
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
