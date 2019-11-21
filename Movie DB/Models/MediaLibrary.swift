//
//  MediaLibrary.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

/// Represents a wrapper for the Media array conforming to `ObservableObject` and adding a few convenience functions
class MediaLibrary: ObservableObject {
    
    /// The key used to store the media array in the user defaults
    private let userDefaultsKey = "mediaList"
    
    @Published var mediaList: [Media]
    
    init() {
        // Load the list from user defaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            self.mediaList = (try? PropertyListDecoder().decode([Media].self, from: data)) ?? []
        } else {
            self.mediaList = []
        }
        // Set up the notifications to save when the app enters background
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func save() {
        // Encode the array into a property list
        let pList = try? PropertyListEncoder().encode(self.mediaList)
        UserDefaults.standard.set(pList, forKey: userDefaultsKey)
        print("Library saved")
    }
    
}
