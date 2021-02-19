//
//  TestingUtils.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 29.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import XCTest
@testable import Movie_DB

struct TestingUtils {
    static func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
        let data: Data
        
        guard let file = Bundle(identifier: "de.JonasFrey.Movie-DBTests")!.url(forResource: filename, withExtension: nil)
            else {
                fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
    
    static let matrixMovie: Movie = {
        let m = Movie(context: <#T##NSManagedObjectContext#>, tmdbData: <#T##TMDBData#>)
        m.personalRating = .twoAndAHalfStars
        m.tags = ["Future", "Conspiracy", "Dark"].compactMap({ name in
            if TagLibrary.shared.tags.contains(where: { $0.name == name }) {
                return TagLibrary.shared.tags.first(where: { $0.name == name })?.id
            } else {
                return TagLibrary.shared.create(name: name)
            }
        })
        m.notes = ""
        m.watched = true
        m.watchAgain = false
        // We can't assign this directly, because he will load it as TMDBData, instead of TMDBShowData
        let movieData: TMDBData = load("Matrix.json")
        m.tmdbData = movieData
        return m
    }()
    
    static let fightClubMovie: Movie = {
        let m = Movie()
        m.personalRating = .noRating
        m.tags = ["Dark", "Violent"].compactMap({ name in
            if TagLibrary.shared.tags.contains(where: { $0.name == name }) {
                return TagLibrary.shared.tags.first(where: { $0.name == name })?.id
            } else {
                return TagLibrary.shared.create(name: name)
            }
        })
        m.notes = "Never watched it..."
        m.watched = false
        m.watchAgain = nil
        // We can't assign this directly, because he will load it as TMDBData, instead of TMDBShowData
        let movieData: TMDBMovieData = load("FightClub.json")
        m.tmdbData = movieData
        return m
    }()
    
    static let blacklistShow: Show = {
        let s = Show()
        s.personalRating = .fiveStars
        s.tags = ["Gangsters", "Conspiracy", "Terrorist"].compactMap({ name in
            if TagLibrary.shared.tags.contains(where: { $0.name == name }) {
                return TagLibrary.shared.tags.first(where: { $0.name == name })?.id
            } else {
                return TagLibrary.shared.create(name: name)
            }
        })
        s.notes = "A masterpiece!"
        s.lastWatched = .init(season: 7, episode: nil)
        s.watchAgain = true
        // We can't assign this directly, because he will load it as TMDBData, instead of TMDBShowData
        let showData: TMDBShowData = load("Blacklist.json")
        s.tmdbData = showData
        return s
    }()
    
    static let gameOfThronesShow: Show = {
        let s = Show()
        s.personalRating = .twoAndAHalfStars
        s.tags = ["Past", "Fantasy"].compactMap({ name in
            if TagLibrary.shared.tags.contains(where: { $0.name == name }) {
                return TagLibrary.shared.tags.first(where: { $0.name == name })?.id
            } else {
                return TagLibrary.shared.create(name: name)
            }
        })
        s.notes = "Bad ending"
        s.lastWatched = .init(season: 8, episode: 3)
        s.watchAgain = false
        // We can't assign this directly, because he will load it as TMDBData, instead of TMDBShowData
        let showData: TMDBShowData = load("GameOfThrones.json")
        s.tmdbData = showData
        return s
    }()
    
    static let mediaSamples = [matrixMovie, fightClubMovie, blacklistShow, gameOfThronesShow]
}

// MARK: - Global Testing Utilities

/// Tests each element of the array by itself, to get a more local error
func assertEqual<T>(_ value1: [T], _ value2: [T]) where T: Equatable {
    XCTAssertEqual(value1.count, value2.count)
    for i in 0..<value1.count {
        XCTAssertEqual(value1[i], value2[i])
    }
}

/// Tests if a date equals the given components
func assertEqual(_ date: Date?, _ year: Int, _ month: Int, _ day: Int) {
    XCTAssertNotNil(date)
    var cal = Calendar.current
    cal.timeZone = TimeZone(secondsFromGMT: 0)!
    XCTAssertEqual(cal.component(.year, from: date!), year)
    XCTAssertEqual(cal.component(.month, from: date!), month)
    XCTAssertEqual(cal.component(.day, from: date!), day)
}

/// Tests, if the first array is completely part of the other array
func assertContains<T>(_ value: [T], in other: [T]) where T: Equatable {
    XCTAssertLessThanOrEqual(value.count, other.count)
    for element in value {
        XCTAssertTrue(other.contains(element))
    }
}
