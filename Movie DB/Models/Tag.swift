//
//  Tag.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

struct Tag: Codable, Identifiable, Hashable, Equatable {
    
    static var nextID: Int {
        allTags.count
    }
    
    static var allTags: [Tag] {
        UserDefaults.standard.array(forKey: JFLiterals.Keys.allTags) as? [Tag] ?? []
    }
    
    init(_ name: String) {
        self.name = name
    }
    
    let id: Int = nextID
    let name: String
}
