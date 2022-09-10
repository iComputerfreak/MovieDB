//
//  CSVCoderTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 03.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import CoreData
import JFUtils
@testable import Movie_DB
import XCTest

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
        
    func testEncodeDecode() throws {
        // MARK: Encode
        let sortedSamples = testingUtils.mediaSamples.sorted(by: \.title)
        let csv = CSVManager.createCSV(from: sortedSamples)
        
        // MARK: Decode
        CSVHelper.importMediaObjects(csvString: csv, importContext: testingUtils.context) { mediaObjects, _ in
            do {
                XCTAssertEqual(mediaObjects.count, sortedSamples.count)
                
                for i in 0..<mediaObjects.count {
                    let media = try XCTUnwrap(mediaObjects[i])
                    let sample = try XCTUnwrap(sortedSamples[i])
                    
                    XCTAssertEqual(media.type, sample.type)
                    XCTAssertEqual(media.tmdbID, sample.tmdbID)
                    XCTAssertEqual(media.title, sample.title)
                    XCTAssertEqual(media.personalRating, sample.personalRating)
                    XCTAssertEqual(media.watchAgain, sample.watchAgain)
                    XCTAssertEqual(media.tags.map(\.name).sorted(), sample.tags.map(\.name).sorted())
                    XCTAssertEqual(media.notes, sample.notes)
                    XCTAssertEqual(media.originalTitle, sample.originalTitle)
                    XCTAssertEqual(media.isAdultMovie, sample.isAdultMovie)
                    XCTAssertEqual(media.missingInformation(), sample.missingInformation())
                    
                    if media.type == .movie, let movie = media as? Movie, let movieSample = sample as? Movie {
                        XCTAssertEqual(movie.isAdult, movieSample.isAdult)
                        XCTAssertEqual(movie.watched, movieSample.watched)
                        // TODO: More properties
                    } else if media.type == .show, let show = media as? Show, let showSample = sample as? Show {
                        XCTAssertEqual(show.showType, showSample.showType)
                        XCTAssertEqual(show.watched, showSample.watched)
                        // TODO: More properties
                    } else {
                        XCTFail("Media is neither a movie, nor a show")
                    }
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
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
            XCTAssertEqual(data[.movieWatched], movie.watched?.rawValue ?? "")
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
            XCTAssertEqual(data[.showWatched], show.watched?.rawValue ?? "")
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
        XCTAssertEqual(lines[2], ";,\";watched;;\(media.id?.uuidString ?? "");Welcome to the Real World.;The Matrix;The Matrix;Action,Science Fiction;Set in the 22nd century, The Matrix tells the story of a computer hacker who joins a group of underground insurgents fighting the vast and powerful computers who now rule the earth.;Released;1999-03-30;136;63000000;463517383;false;;;;;;;\(CSVManager.dateTimeFormatter.string(from: media.creationDate));\(media.modificationDate.map { CSVManager.dateTimeFormatter.string(from: $0) } ?? "")")
    }
}
