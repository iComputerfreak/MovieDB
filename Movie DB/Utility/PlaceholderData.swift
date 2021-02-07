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
    
    static var tmdbMovieData: TMDBData {
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "TMDBMovie", withExtension: "json")!)
        return try! JSONDecoder().decode(TMDBData.self, from: data)
    }
    
    static var tmdbShowData: TMDBData {
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "TMDBShow", withExtension: "json")!)
        return try! JSONDecoder().decode(TMDBData.self, from: data)
    }
    
    static let movie: Movie = {
        let m = Movie(context: AppDelegate.viewContext, tmdbData: tmdbMovieData)
        m.personalRating = .twoAndAHalfStars
        m.tags = [0, 1, 2]
        return m
    }()
    
    static let show: Show = {
        let s = Show(context: AppDelegate.viewContext, tmdbData: tmdbShowData)
        s.personalRating = .fourStars
        s.tags = [2, 3]
        return s
    }()
    
    static var mediaLibrary: MediaLibrary {
        let library = MediaLibrary.shared
        try! library.append(movie)
        try! library.append(show)
        return library
    }
    
    static func populateSampleTags() {
        let lib = TagLibrary.shared
        try! lib.create(name: "Happy Ending")
        try! lib.create(name: "Trashy")
        try! lib.create(name: "Time Travel")
        try! lib.create(name: "Immortality")
    }
}
