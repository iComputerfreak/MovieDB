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
    
    static let movie = Media(type: .movie, tmdbData: Self.tmdbMovieData, justWatchData: nil, personalRating: 3, tags: ["tag1", "tag2", "tag3"])
    static let show = Media(type: .show, tmdbData: Self.tmdbShowData, justWatchData: nil, personalRating: 5, tags: ["tag1", "tag2", "tag4"])
    
    static var mediaLibrary: MediaLibrary {
        let library = MediaLibrary()
        library.mediaList.append(movie)
        library.mediaList.append(show)
        return library
    }
}
