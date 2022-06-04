//
//  TestingUtils.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 29.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import XCTest
import CoreData
@testable import Movie_DB

// swiftlint:disable prefer_self_in_static_references

struct TestingUtils {
    let context: NSManagedObjectContext
    
    let previewTags: Set<Tag>
    let matrixMovie: Movie
    let fightClubMovie: Movie
    let blacklistShow: Show // swiftlint:disable:this inclusive_language
    let gameOfThronesShow: Show
    var mediaSamples: [Media]
    
    init() {
        let context = PersistenceController.createTestingContext()
        self.context = context
        let previewTags: Set<Tag> = [
            Tag(name: "Future", context: context),
            Tag(name: "Conspiracy", context: context),
            Tag(name: "Dark", context: context),
            Tag(name: "Violent", context: context),
            Tag(name: "Gangsters", context: context),
            Tag(name: "Terrorist", context: context),
            Tag(name: "Past", context: context),
            Tag(name: "Fantasy", context: context)
        ]
        self.previewTags = previewTags
        self.matrixMovie = {
            let tmdbData: TMDBData = TestingUtils.load("Matrix.json", mediaType: .movie, into: context)
            let m = Movie(context: context, tmdbData: tmdbData)
            m.personalRating = .twoAndAHalfStars
            m.tags = TestingUtils.getPreviewTags(["Future", "Conspiracy", "Dark"], of: previewTags)
            m.notes = ""
            m.watched = .watched
            m.watchAgain = false
            return m
        }()
        self.fightClubMovie = {
            let tmdbData: TMDBData = TestingUtils.load("FightClub.json", mediaType: .movie, into: context)
            let m = Movie(context: context, tmdbData: tmdbData)
            m.personalRating = .noRating
            m.tags = TestingUtils.getPreviewTags(["Dark", "Violent"], of: previewTags)
            m.notes = "Never watched it..."
            m.watched = .notWatched
            m.watchAgain = nil
            return m
        }()
        self.blacklistShow = {
            let tmdbData: TMDBData = TestingUtils.load("Blacklist.json", mediaType: .show, into: context)
            let s = Show(context: context, tmdbData: tmdbData)
            s.personalRating = .fiveStars
            s.tags = TestingUtils.getPreviewTags(["Gangsters", "Conspiracy", "Terrorist"], of: previewTags)
            s.notes = "A masterpiece!"
            s.lastWatched = .init(season: 7, episode: nil)
            s.watchAgain = true
            return s
        }()
        self.gameOfThronesShow = {
            let tmdbData: TMDBData = TestingUtils.load("GameOfThrones.json", mediaType: .show, into: context)
            let s = Show(context: context, tmdbData: tmdbData)
            s.personalRating = .twoAndAHalfStars
            s.tags = TestingUtils.getPreviewTags(["Past", "Fantasy"], of: previewTags)
            s.notes = "Bad ending"
            s.lastWatched = .init(season: 8, episode: 3)
            s.watchAgain = false
            return s
        }()
        self.mediaSamples = [matrixMovie, fightClubMovie, blacklistShow, gameOfThronesShow]
    }
    
    static func load<T: Decodable>(
        _ filename: String,
        mediaType: MediaType? = nil,
        into context: NSManagedObjectContext,
        as type: T.Type = T.self
    ) -> T {
        let data: Data
        
        guard
            let file = Bundle(for: APITests.self).url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in test bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from test bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.userInfo[.managedObjectContext] = context
            decoder.userInfo[.mediaType] = mediaType
            return try decoder.decode(T.self, from: data)
        } catch let error {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
    
    static func getPreviewTags(_ tagNames: [String], of tags: Set<Tag>) -> Set<Tag> {
        Set(tagNames.map { name in
            let tag = tags.first { tag in
                tag.name == name
            }
            guard let tag = tag else {
                fatalError("Preview Tag \(name) does not exist.")
            }
            return tag
        })
    }
                     
    func getPreviewTags(_ tagNames: [String]) -> Set<Tag> {
        TestingUtils.getPreviewTags(tagNames, of: self.previewTags)
    }
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
        XCTAssertTrue(other.contains(element), "\(element) not found.")
    }
}

extension SeasonDummy {
    init(
        id: Int,
        seasonNumber: Int,
        episodeCount: Int,
        name: String,
        overview: String?,
        imagePath: String?,
        rawAirDate: String?
    ) {
        let airDate = rawAirDate.map { Utils.tmdbDateFormatter.date(from: $0) }
        self.init(
            id: id,
            seasonNumber: seasonNumber,
            episodeCount: episodeCount,
            name: name,
            overview: overview,
            imagePath: imagePath,
            // swiftlint:disable:next redundant_nil_coalescing
            airDate: airDate ?? nil
        )
    }
}
