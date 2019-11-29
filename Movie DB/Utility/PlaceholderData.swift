//
//  SampleData.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

struct PlaceholderData {
    
    static var rawMovieJSON: Data {
        try! Data(contentsOf: Bundle.main.url(forResource: "TMDBMovie", withExtension: "json")!)
    }
    
    static var tmdbMovieData: TMDBMovieData {
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "TMDBMovie", withExtension: "json")!)
        return try! JSONDecoder().decode(TMDBMovieData.self, from: data)
    }
    static var tmdbShowData: TMDBShowData {
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "TMDBShow", withExtension: "json")!)
        return try! JSONDecoder().decode(TMDBShowData.self, from: data)
    }
    
    // Use fixed IDs < 0, to prevent collision and prevent counting the static variable up
    static let movie = Movie(id: -1, type: .movie, tmdbData: Self.tmdbMovieData, personalRating: 5, tags: [0, 1, 2])
    static let show = Show(id: -2, type: .show, tmdbData: Self.tmdbShowData, personalRating: 8, tags: [2, 3])
    
    static var mediaLibrary: MediaLibrary {
        let library = MediaLibrary.shared
        library.mediaList.append(movie)
        library.mediaList.append(show)
        return library
    }
    
    static func populateSampleTags() {
        let lib = TagLibrary.shared
        lib.create(name: "Happy Ending")
        lib.create(name: "Trashy")
        lib.create(name: "Time Travel")
        lib.create(name: "Immortality")
    }
}
