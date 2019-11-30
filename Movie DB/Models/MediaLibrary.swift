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
        // Contains the page and results
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Contains the TMDBSearchResults array
        // Create two identical containers, so we can extract the same value twice
        var mediaObjects = try container.nestedUnkeyedContainer(forKey: .mediaList)
        var mediaObjects2 = try container.nestedUnkeyedContainer(forKey: .mediaList)
        assert(mediaObjects.count == mediaObjects2.count)
        while (!mediaObjects.isAtEnd) {
            // Get the Movie or Show as a GenericMedia object
            let movieOrShowContainer = try mediaObjects.nestedContainer(keyedBy: GenericMedia.CodingKeys.self)
            // Get the Media container (super container) from the Movie/Show
            let mediaTypeContainer = try movieOrShowContainer.superDecoder().container(keyedBy: GenericMedia.CodingKeys.self)
            // Read the type of the Media container
            let mediaType = try mediaTypeContainer.decode(MediaType.self, forKey: .type)
            // Decide based on the media type which type to use for decoding
            switch mediaType {
                case .movie:
                    self.mediaList.append(try mediaObjects2.decode(Movie.self))
                case .show:
                    self.mediaList.append(try mediaObjects2.decode(Show.self))
            }
        }
        print("Loaded \(self.mediaList.count) Media objects.")
    }
    
    private struct Empty: Decodable {}
    
    private struct GenericMedia: Codable {
        var type: MediaType
        enum CodingKeys: String, CodingKey {
            case type
        }
    }
    
    func encode(to encoder: Encoder) throws {
        // Encode all Media Objects
        var container = encoder.container(keyedBy: CodingKeys.self)
        var arrayContainer = container.nestedUnkeyedContainer(forKey: .mediaList)
        for media in mediaList {
            if media.type == .movie {
                try arrayContainer.encode(media as! Movie)
            } else {
                try arrayContainer.encode(media as! Show)
            }
        }
    }
    
    enum CodingKeys: CodingKey {
        case mediaList
    }
    
}
