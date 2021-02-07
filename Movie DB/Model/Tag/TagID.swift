//
//  TagID.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation

struct TagID {
    
    // Tag ID Creation
    /// Contains the next free collection id
    private static var _nextID = 0
    /// Returns the next free tag id
    static var nextID: Int {
        print("Requesting new Tag ID.")
        // Initialize
        if _nextID <= 0 {
            _nextID = UserDefaults.standard.integer(forKey: "nextTagID")
            if _nextID == 0 {
                // No id saved in user defaults. Lets start at 1
                _nextID = 1
            }
        }
        // Increase _nextID after returning
        defer {
            _nextID += 1
            UserDefaults.standard.set(_nextID, forKey: "nextTagID")
        }
        print("Returning new Tag ID \(_nextID)")
        return _nextID
    }
    
    /// Resets the nextID property
    static func resetNextID() {
        _nextID = 0
        UserDefaults.standard.set(_nextID, forKey: "nextTagID")
    }
    
}
