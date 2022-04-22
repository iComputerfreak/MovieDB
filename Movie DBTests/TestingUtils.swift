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

// swiftlint:disable private_over_fileprivate
// swiftlint:disable function_parameter_count
// swiftlint:disable prefer_self_in_static_references

struct TestingUtils {
    
    let context: NSManagedObjectContext
    
    static func load<T: Decodable>(
        _ filename: String,
        mediaType: MediaType? = nil,
        into context: NSManagedObjectContext,
        as type: T.Type = T.self
    ) -> T {
        let data: Data
        
        guard
            let file = Bundle(identifier: "de.JonasFrey.Movie-DBTests")!.url(forResource: filename, withExtension: nil)
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
            decoder.userInfo[.managedObjectContext] = context
            decoder.userInfo[.mediaType] = mediaType
            return try decoder.decode(T.self, from: data)
        } catch let error {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
    
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
            m.watched = true
            m.watchAgain = false
            return m
        }()
        self.fightClubMovie = {
            let tmdbData: TMDBData = TestingUtils.load("FightClub.json", mediaType: .movie, into: context)
            let m = Movie(context: context, tmdbData: tmdbData)
            m.personalRating = .noRating
            m.tags = TestingUtils.getPreviewTags(["Dark", "Violent"], of: previewTags)
            m.notes = "Never watched it..."
            m.watched = false
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
    
    let previewTags: Set<Tag>
    let matrixMovie: Movie
    let fightClubMovie: Movie
    let blacklistShow: Show // swiftlint:disable:this inclusive_language
    let gameOfThronesShow: Show
    var mediaSamples: [Media]
    
    static func getPreviewTags(_ tagNames: [String], of tags: Set<Tag>) -> Set<Tag> {
        return Set(tagNames.map({ name in
            let tag = tags.first { tag in
                tag.name == name
            }
            guard let tag = tag else {
                fatalError("Preview Tag \(name) does not exist.")
            }
            return tag
        }))
    }
                     
    func getPreviewTags(_ tagNames: [String]) -> Set<Tag> {
        return TestingUtils.getPreviewTags(tagNames, of: self.previewTags)
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

// MARK: assertEqual() overloads for specific NSManagedObjects

fileprivate struct ProductionCompanyDummy: Equatable {
    
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String
    
    init(_ pc: ProductionCompany) {
        self.id = pc.id
        self.name = pc.name
        self.logoPath = pc.logoPath
        self.originCountry = pc.originCountry
    }
}

func assertEqual(_ value1: [ProductionCompany], _ value2: [ProductionCompany]) {
    let pc1 = value1.map(ProductionCompanyDummy.init)
    let pc2 = value2.map(ProductionCompanyDummy.init)
    assertEqual(pc1, pc2)
}

fileprivate struct GenreDummy: Equatable {
    
    let id: Int
    let name: String
    
    init(_ genre: Genre) {
        self.id = genre.id
        self.name = genre.name
    }
}

func assertEqual(_ value1: [Genre], _ value2: [Genre]) {
    let genre1 = value1.map(GenreDummy.init)
    let genre2 = value2.map(GenreDummy.init)
    assertEqual(genre1, genre2)
}

fileprivate struct VideoDummy: Equatable {
    
    let key: String
    let name: String
    let site: String
    let type: String
    let resolution: Int
    let language: String
    let region: String
    
    init(_ video: Video) {
        self.key = video.key
        self.name = video.name
        self.site = video.site
        self.type = video.type
        self.resolution = video.resolution
        self.language = video.language
        self.region = video.region
    }
}

func assertEqual(_ value1: [Video], _ value2: [Video]) {
    let video1 = value1.map(VideoDummy.init)
    let video2 = value2.map(VideoDummy.init)
    assertEqual(video1, video2)
}

fileprivate struct CastMemberDummy: Equatable {
    
    let id: Int
    let name: String
    let roleName: String
    let imagePath: String?
    
    init(_ cm: CastMember) {
        self.id = cm.id
        self.name = cm.name
        self.roleName = cm.roleName
        self.imagePath = cm.imagePath
    }
}

func assertEqual(_ value1: [CastMember], _ value2: [CastMember]) {
    let cm1 = value1.map(CastMemberDummy.init)
    let cm2 = value2.map(CastMemberDummy.init)
    assertEqual(cm1, cm2)
}

fileprivate struct SeasonDummy: Equatable {
    
    let id: Int
    let seasonNumber: Int
    let episodeCount: Int
    let name: String
    let overview: String?
    let imagePath: String?
    let airDate: Date?
    let show: Show?
    
    init(_ season: Season) {
        self.id = season.id
        self.seasonNumber = season.seasonNumber
        self.episodeCount = season.episodeCount
        self.name = season.name
        self.overview = season.overview
        self.imagePath = season.imagePath
        self.airDate = season.airDate
        self.show = season.show
    }
}

func assertEqual(_ value1: [Season], _ value2: [Season]) {
    let season1 = value1.map(SeasonDummy.init)
    let season2 = value2.map(SeasonDummy.init)
    assertEqual(season1, season2)
}

/// Tests, if the first array is completely part of the other array
func assertContains<T>(_ value: [T], in other: [T]) where T: Equatable {
    XCTAssertLessThanOrEqual(value.count, other.count)
    for element in value {
        XCTAssertTrue(other.contains(element))
    }
}

func assertContains(_ value: [CastMember], in other: [CastMember]) {
    assertContains(value.map(CastMemberDummy.init), in: other.map(CastMemberDummy.init))
}

// MARK: - Testing Initializers

extension ProductionCompany {
    static func create(
        context: NSManagedObjectContext,
        id: Int,
        name: String,
        logoPath: String?,
        originCountry: String
    ) -> ProductionCompany {
        let c = ProductionCompany(context: context)
        c.id = id
        c.name = name
        c.logoPath = logoPath
        c.originCountry = originCountry
        return c
    }
}

extension Genre {
    static func create(context: NSManagedObjectContext, id: Int, name: String) -> Genre {
        let g = Genre(context: context)
        g.id = id
        g.name = name
        return g
    }
}

extension Video {
    static func create(
        context: NSManagedObjectContext,
        key: String,
        name: String,
        site: String,
        type: String,
        resolution: Int,
        language: String,
        region: String
    ) -> Video {
        let v = Video(context: context)
        v.key = key
        v.name = name
        v.site = site
        v.type = type
        v.resolution = resolution
        v.language = language
        v.region = region
        return v
    }
}

extension CastMember {
    static func create(
        context: NSManagedObjectContext,
        id: Int,
        name: String,
        roleName: String,
        imagePath: String?
    ) -> CastMember {
        let c = CastMember(context: context)
        c.id = id
        c.name = name
        c.roleName = roleName
        c.imagePath = imagePath
        return c
    }
}

extension Season {
    static func create(
        context: NSManagedObjectContext,
        id: Int,
        seasonNumber: Int,
        episodeCount: Int,
        name: String,
        overview: String?,
        imagePath: String?,
        rawAirDate: String
    ) -> Season {
        let s = Season(context: context)
        s.id = id
        s.seasonNumber = seasonNumber
        s.episodeCount = episodeCount
        s.name = name
        s.overview = overview
        s.imagePath = imagePath
        s.airDate = Utils.tmdbDateFormatter.date(from: rawAirDate)!
        return s
    }
}
