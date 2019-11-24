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
class MediaLibrary: ObservableObject, Codable {
    
    /// The shared `MediaLibrary` instance.
    static let shared = MediaLibrary.load()
    
    @Published var mediaList: [Media]
    
    private init() {
        self.mediaList = []
        // Set up the notifications to save when the app enters background
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    /// Loads the media library from the user defaults, or returns a new one, if none was saved.
    static func load() -> MediaLibrary {
        // Load the media library from user defaults
        if let data = UserDefaults.standard.data(forKey: JFLiterals.Keys.mediaLibrary) {
            return (try? PropertyListDecoder().decode(MediaLibrary.self, from: data)) ?? MediaLibrary()
        } else {
            return MediaLibrary()
        }
    }
    
    /// Saves this media library to the user defaults
    @objc func save() {
        // Encode the array into a property list
        let pList = try? PropertyListEncoder().encode(self)
        UserDefaults.standard.set(pList, forKey: JFLiterals.Keys.mediaLibrary)
        print("Library saved")
    }
    
    // MARK: - Codable Conformance
    required convenience init(from decoder: Decoder) throws {
        self.init()
        // Loops through all the container entries and add them to the mediaList as either a Movie or a Show
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mediaObjects = try container.decode([Media].self, forKey: .mediaList)
        for entity in mediaObjects {
            if entity.type == .movie {
                self.mediaList.append(entity as! Movie)
            } else {
                self.mediaList.append(entity as! Show)
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        // Encode all Media Objects
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mediaList, forKey: .mediaList)
    }
    
    enum CodingKeys: CodingKey {
        case mediaList
    }
    
}
