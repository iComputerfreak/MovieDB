//
//  Series.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit

class Show: Media {
    
    typealias EpisodeNumber = (season: Int, episode: Int)
    
    /// The season and episode number of the episode, the user has watched most recently
    @Published var lastEpisode: EpisodeNumber?
    
    override var tmdbData: TMDBData? {
        didSet {
            loadSeasonThumbnails()
        }
    }
    
    @Published private(set) var seasonThumbnails: [ObjectIdentifier: UIImage?] = [:]
    
    func loadSeasonThumbnails() {
        guard let showData = self.tmdbData as? TMDBShowData else {
            return
        }
        guard !showData.seasons.isEmpty else {
            return
        }
        print("Loading season thumbnails for \(self.tmdbData?.title ?? "Unknown")")
        for season in showData.seasons {
            if let imagePath = season.imagePath {
                JFUtils.loadImage(urlString: imagePath) { (image) in
                    DispatchQueue.main.async {
                        self.seasonThumbnails[season.id] = image
                    }
                }
            }
        }
    }
    
}
