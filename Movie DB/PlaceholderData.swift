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
    
    static let movie = Movie(type: .movie, tmdbData: Self.tmdbMovieData, justWatchData: nil, personalRating: 5, tags: [Tag("tag1"), Tag("tag2"), Tag("tag3")])
    static let show = Show(type: .show, tmdbData: Self.tmdbShowData, justWatchData: nil, personalRating: 8, tags: [Tag("tag1"), Tag("tag2"), Tag("tag4")])
    
    static var mediaLibrary: MediaLibrary {
        let library = MediaLibrary.shared
        library.mediaList.append(movie)
        library.mediaList.append(show)
        return library
    }
}
