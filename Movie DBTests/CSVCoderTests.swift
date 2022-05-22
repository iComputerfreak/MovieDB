//
//  CSVCoderTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 03.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import XCTest
import JFUtils
@testable import Movie_DB
import CoreData

// swiftlint:disable line_length
class CSVCoderTests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var testingUtils: TestingUtils!
    
    override func setUp() {
        super.setUp()
        testingUtils = TestingUtils()
    }
    
    override func tearDown() {
        super.tearDown()
        testingUtils = nil
    }
        
    func testDecode() throws {
        let sample1 = """
        id;tmdb_id;type;title;personal_rating;watch_again;tags;notes;original_title;genres;overview;status;watched;release_date;runtime;budget;revenue;is_adult;last_episode_watched;first_air_date;last_air_date;number_of_seasons;is_in_production;show_type
        113;346808;movie;Momentum;8;true;Female Lead,Gangsters,Kidnapping,Revenge;;Momentum;Action,Thriller;When Alex, an infiltration expert with a secret past, accidentally reveals her identity during what should have been a routine heist, she quickly finds herself mixed up in a government conspiracy and entangled in a deadly game of cat-and-mouse with a master assassin and his team of killers.  Armed with her own set of lethal skills, Alex looks to exact revenge for her murdered friends while uncovering the truth.;Released;true;2015-08-01;96;20000000;133332;false;;;;;;
        157;75219;tv;9-1-1;2;true;Crime;A very great series;9-1-1;Drama,Action & Adventure,Crime;Explore the high-pressure experiences of police officers, paramedics and firefighters who are thrust into the most frightening, shocking and heart-stopping situations. These emergency responders must try to balance saving those who are at their most vulnerable with solving the problems in their own lives.;Returning Series;;;;;;;3;2018-01-03;2020-05-11;3;true;Scripted
        125;79130;tv;Another Life;1;false;Artificial Intelligence,Aliens,Female Lead,Haunted,Future,Horror,Space,Extinction Level Event;;Another Life;Drama,Sci-Fi & Fantasy;After a massive alien artifact lands on Earth, Niko Breckinridge leads an interstellar mission to track down its source and make first contact.;Returning Series;;;;;;;3/5;2019-07-25;2019-07-25;1;true;Scripted
        116;399402;movie;Hunter Killer;0;false;;A note with some special characters.\\/:?!;Hunter Killer;Action,Thriller;;Released;true;2018-10-19;122;0;0;false;;;;;;
        """
        CSVHelper.importMediaObjects(csvString: sample1, importContext: testingUtils.context) { mediaObjects, _ in
            do {
                XCTAssertEqual(mediaObjects.count, 4)
                
                for media in mediaObjects {
                    XCTAssertNotNil(media)
                }
                
                // MARK: Momentum
                XCTAssertEqual(mediaObjects[0]!.type, .movie)
                let momentum = try XCTUnwrap(mediaObjects[0] as? Movie)
                try self.testDecodeMomentum(momentum)
                
                // MARK: 9-1-1
                XCTAssertEqual(mediaObjects[1]!.type, .show)
                let nineOneOne = try XCTUnwrap(mediaObjects[1] as? Show)
                try self.testDecodeNineOneOne(nineOneOne)
                
                // MARK: Another Life
                XCTAssertEqual(mediaObjects[2]!.type, .show)
                let anotherLife = try XCTUnwrap(mediaObjects[2] as? Show)
                try self.testDecodeAnotherLife(anotherLife)
                
                // MARK: Hunter Killer
                XCTAssertEqual(mediaObjects[3]!.type, .movie)
                let hunterKiller = try XCTUnwrap(mediaObjects[3] as? Movie)
                try self.testDecodeHunterKiller(hunterKiller)
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    private func testDecodeMomentum(_ media: Movie) throws {
        // The ID has not to be the same, as in the CSV. The ID will be re-issued
        XCTAssertEqual(media.tmdbID, 346808)
        XCTAssertEqual(media.title, "Momentum")
        XCTAssertEqual(media.personalRating, .fourStars)
        XCTAssertEqual(media.watchAgain, true)
        XCTAssertEqual(media.tags.map(\.name), ["Female Lead", "Gangsters", "Kidnapping", "Revenge"])
        XCTAssertEqual(media.notes, "")
        XCTAssertEqual(media.originalTitle, "Momentum")
        XCTAssertEqual(media.isAdult, false)
        XCTAssertEqual(media.isAdultMovie, false)
        
        XCTAssertEqual(media.watched, .watched)
        XCTAssertEqual(media.missingInformation(), Set<Media.MediaInformation>())
    }
    
    private func testDecodeNineOneOne(_ media: Show) throws {
        // The ID has not to be the same, as in the CSV. The ID will be re-issued
        XCTAssertEqual(media.tmdbID, 75219)
        XCTAssertEqual(media.title, "9-1-1")
        XCTAssertEqual(media.personalRating, .oneStar)
        XCTAssertEqual(media.watchAgain, true)
        XCTAssertEqual(media.tags.map(\.name), ["Crime"])
        XCTAssertEqual(media.notes, "A very great series")
        XCTAssertEqual(media.originalTitle, "9-1-1")
        XCTAssertEqual(media.showType, .scripted)
        
        XCTAssertEqual(media.lastWatched, .init(season: 3))
        XCTAssertEqual(media.missingInformation(), Set<Media.MediaInformation>())
    }
    
    private func testDecodeAnotherLife(_ media: Show) throws {
        // The ID has not to be the same, as in the CSV. The ID will be re-issued
        XCTAssertEqual(media.tmdbID, 79130)
        XCTAssertEqual(media.title, "Another Life")
        XCTAssertEqual(media.personalRating, .halfStar)
        XCTAssertEqual(media.watchAgain, false)
        XCTAssertEqual(media.tags.map(\.name), ["Artificial Intelligence", "Aliens", "Female Lead", "Haunted", "Future", "Horror", "Space", "Extinction Level Event"])
        XCTAssertEqual(media.notes, "")
        XCTAssertEqual(media.originalTitle, "Another Life")
        XCTAssertEqual(media.showType, .scripted)
        
        XCTAssertEqual(media.lastWatched, .init(season: 3, episode: 5))
        XCTAssertEqual(media.missingInformation(), Set<Media.MediaInformation>())
    }
    
    private func testDecodeHunterKiller(_ media: Movie) throws {
        // The ID has not to be the same, as in the CSV. The ID will be re-issued
        XCTAssertEqual(media.tmdbID, 399402)
        XCTAssertEqual(media.title, "Hunter Killer")
        XCTAssertEqual(media.personalRating, .noRating)
        XCTAssertEqual(media.watchAgain, false)
        XCTAssertEqual(media.tags, [])
        XCTAssertEqual(media.notes, "A note with some special characters.\\/:?!")
        XCTAssertEqual(media.originalTitle, "Hunter Killer")
        XCTAssertEqual(media.isAdult, false)
        XCTAssertEqual(media.isAdultMovie, false)
        
        XCTAssertEqual(media.watched, .watched)
        XCTAssertEqual(media.missingInformation(), Set<Media.MediaInformation>([.rating, .tags]))
    }
    
    func testEncode() throws {
        let sortedSamples = testingUtils.mediaSamples.sorted(by: \.title)
        let csv = CSVManager.createCSV(from: sortedSamples)
        let lines = csv.components(separatedBy: CSVManager.lineSeparator)
        // We should get an extra line for the header
        XCTAssertEqual(lines.count, sortedSamples.count + 1)
        
        // MARK: Header
        let csvHeaders = lines.first!.components(separatedBy: CSVManager.separator)
        XCTAssertEqual(csvHeaders.count, CSVManager.exportKeys.count)
        for i in 0..<CSVManager.exportKeys.count {
            let header = CSVManager.exportKeys[i]
            let csvHeader = csvHeaders[i]
            XCTAssertEqual(header.rawValue, csvHeader)
        }
        
        // Map the values to their headers to make a dictionary
        let components: [[String]] = lines.dropFirst().map { $0.components(separatedBy: CSVManager.separator) }
        var dictionaries: [[CSVManager.CSVKey: String]] = []
        for line in components {
            XCTAssertEqual(line.count, CSVManager.exportKeys.count)
            let pairs = (0..<CSVManager.exportKeys.count).map { i -> (CSVManager.CSVKey, String) in
                let header = CSVManager.exportKeys[i]
                let value = line[i]
                return (header, value)
            }
            dictionaries.append(Dictionary(uniqueKeysWithValues: pairs))
        }
        
        // We have to match the media object with their CSV line, as they all get sorted when exported
        // Test all sample media objects
        for i in 0..<sortedSamples.count {
            try testEncodedMedia(dictionaries[i], encodedMedia: sortedSamples[i])
        }
    }
    
    private func testEncodedMedia(_ data: [CSVManager.CSVKey: String], encodedMedia media: Media) throws {
        // data[key] never returns nil, since every value is read from CSV and nil-values in CSV are empty strings
        // If data[key] returns nil, that means, that the CSV value was never read/written and therefore is a bug in the CSVCoder!
        XCTAssertEqual(data[.id], media.id?.uuidString)
        XCTAssertEqual(data[.mediaType], media.type.rawValue)
        XCTAssertEqual(data[.personalRating], media.personalRating.rawValue.description)
        let tagNames = media.tags.map(\.name)
        XCTAssertEqual(data[.tags], tagNames.sorted().joined(separator: CSVManager.arraySeparator))
        // data[key] always returns a string, so we have to map the boolean to its csv-representation (nil == "")
        XCTAssertEqual(data[.watchAgain], media.watchAgain?.description ?? "")
        XCTAssertEqual(data[.notes], media.notes)
        
        XCTAssertEqual(data[.tmdbID], media.tmdbID.description)
        XCTAssertEqual(data[.title], media.title)
        XCTAssertEqual(data[.originalTitle], media.originalTitle)
        let genreNames = media.genres.map(\.name)
        XCTAssertEqual(data[.genres], genreNames.sorted().joined(separator: CSVManager.arraySeparator))
        print("Comparing:")
        print(data[.overview]!)
        print(media.overview!)
        // The encoded quotation marks should be doubled (escaped in the CSV file)
        XCTAssertEqual(data[.overview], media.overview?.replacingOccurrences(of: "\"", with: "\"\"") ?? "")
        XCTAssertEqual(data[.status], media.status.rawValue)
        
        if let movie = media as? Movie {
            // Movie exclusive
            XCTAssertEqual(data[.watched], movie.watched?.rawValue ?? "")
            if let releaseDate = movie.releaseDate {
                XCTAssertEqual(data[.releaseDate], CSVManager.dateFormatter.string(from: releaseDate))
            } else {
                XCTAssertEqual(data[.releaseDate], "")
            }
            XCTAssertEqual(data[.runtime], movie.runtime?.description ?? "")
            XCTAssertEqual(data[.budget], movie.budget.description)
            XCTAssertEqual(data[.revenue], movie.revenue.description)
            XCTAssertEqual(data[.isAdult], movie.isAdult.description)
        } else if let show = media as? Show {
            // Show exclusive
            XCTAssertEqual(data[.lastWatched], show.lastWatched?.description ?? "")
            if let firstAirDate = show.firstAirDate {
                XCTAssertEqual(data[.firstAirDate], CSVManager.dateFormatter.string(from: firstAirDate))
            } else {
                XCTAssertEqual(data[.firstAirDate], "")
            }
            if let lastAirDate = show.lastAirDate {
                XCTAssertEqual(data[.lastAirDate], CSVManager.dateFormatter.string(from: lastAirDate))
            } else {
                XCTAssertEqual(data[.lastAirDate], "")
            }
            XCTAssertEqual(data[.numberOfSeasons], show.numberOfSeasons?.description ?? "")
            XCTAssertEqual(data[.isInProduction], show.isInProduction.description)
            XCTAssertEqual(data[.showType], show.showType?.rawValue ?? "")
        } else {
            XCTFail("Media is neither a movie, nor a show")
        }
    }
    
    func testEncodeMediaWithIllegalCharacters() throws {
        let media = testingUtils.matrixMovie
        let newName = "Illegal\(CSVManager.separator) Tag"
        let tagWithSeparator = Tag(name: newName, context: testingUtils.context)
        media.tags.insert(tagWithSeparator)
        media.notes = "This note contains:\(CSVManager.lineSeparator)\(CSVManager.separator)\(CSVManager.arraySeparator)"
        let csv = CSVManager.createCSV(from: [media])
        let lines = csv.components(separatedBy: CSVManager.lineSeparator)
        // Additional line for the header and the line break in the note
        XCTAssertEqual(lines.count, 3)
        // Fields with illegal characters in the CSV output will be encased in quotation marks
        XCTAssertEqual(lines[1], "603;movie;5;false;\"Conspiracy,Dark,Future,Illegal; Tag\";\"This note contains:")
        XCTAssertEqual(lines[2], ";,\";true;;\(media.id?.uuidString ?? "");The Matrix;The Matrix;Action,Science Fiction;Set in the 22nd century, The Matrix tells the story of a computer hacker who joins a group of underground insurgents fighting the vast and powerful computers who now rule the earth.;Released;1999-03-30;136;63000000;463517383;false;;;;;;\(CSVManager.dateFormatter.string(from: media.creationDate))")
    }
}
