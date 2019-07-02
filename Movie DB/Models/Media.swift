//
//  Media.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class Media: Identifiable, BindableObject {
    typealias PublisherType = PassthroughSubject<Void, Never>
    var didChange = PublisherType()
    
    /// The internal library id
    let id: Int
    /// The data from TMDB
    var tmdbData: TMDBData? {
        didSet {
            didChange.send()
            loadThumbnail()
        }
    }
    /// The data from JustWatch.com
    var justWatchData: JustWatchData? {
        didSet {
            sendChange()
        }
    }
    /// The type of media
    var type: MediaType = .movie {
        didSet {
            sendChange()
        }
    }
    /// A rating between 0 and 10 (no Rating and 5 stars)
    var personalRating: Int {
        didSet {
            sendChange()
        }
    }
    /// A list of user-specified tags
    var tags: [String] {
        didSet {
            sendChange()
        }
    }
    
    private(set) var thumbnail: UIImage? = nil
    
    init(id: Int, tmdbData: TMDBData?, justWatchData: JustWatchData?, type: MediaType, personalRating: Int = 0, tags: [String] = []) {
        self.id = id
        self.tmdbData = tmdbData
        self.justWatchData = justWatchData
        self.type = type
        self.personalRating = personalRating
        self.tags = tags
    }
    
    func sendChange() {
        DispatchQueue.main.sync {
            didChange.send()
        }
    }
    
    func loadThumbnail() {
        guard let tmdbData = self.tmdbData else {
            return
        }
        guard let imagePath = tmdbData.imagePath, !tmdbData.imagePath!.isEmpty else {
            return
        }
        let urlString = JFUtils.getTMDBImageURL(path: imagePath)
        JFUtils.getRequest(urlString, parameters: [:]) { (data) in
            guard let data = data else {
                print("Unable to get image")
                return
            }
            self.thumbnail = UIImage(data: data)
        }
    }
}

enum MediaType: String, Codable {
    case movie = "movie"
    case show = "tv"
}
