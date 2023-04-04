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
import os.log
import SwiftCSV
import XCTest

class CSVCoderTests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var testingUtils: TestingUtils!
    
    let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.timeZone = .utc
        return f
    }()
    
    override func setUp() {
        super.setUp()
        testingUtils = TestingUtils()
        continueAfterFailure = true
    }
    
    override func tearDown() {
        super.tearDown()
        testingUtils = nil
    }
    
    func testEncode() throws {
        let exporter = CSVExporter()
        let sortedSamples = testingUtils.mediaSamples.sorted(on: \.title, by: <)
        let csv = exporter.createCSV(from: sortedSamples)
        let lines = csv.components(separatedBy: exporter.lineSeparator)
        // We should get an extra line for the header
        XCTAssertEqual(lines.count, sortedSamples.count + 1)
        
        // MARK: Header
        let csvHeaders = lines.first!.components(separatedBy: exporter.separator)
        XCTAssertEqual(csvHeaders.count, CSVHelper.exportKeys.count)
        for i in 0..<CSVHelper.exportKeys.count {
            let header = CSVHelper.exportKeys[i]
            let csvHeader = csvHeaders[i]
            XCTAssertEqual(header.rawValue, csvHeader)
        }
        
        // Map the values to their headers to make a dictionary
        let components: [[String]] = lines.dropFirst().map { $0.components(separatedBy: exporter.separator) }
        var dictionaries: [[CSVKey: String]] = []
        for line in components {
            XCTAssertEqual(line.count, CSVHelper.exportKeys.count)
            let pairs = (0..<CSVHelper.exportKeys.count).map { i -> (CSVKey, String) in
                let header = CSVHelper.exportKeys[i]
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
    
    func testEscapedLineBreaks() async throws {
        let csvString = """
        header1;header2;header3
        value1;"value2 goes
        over two lines";value3
        """
        let csv = try CSV<Named>(string: csvString, delimiter: .semicolon)
        XCTAssertEqual(csv.header.count, 3)
        XCTAssertEqual(csv.rows.count, 1)
    }
        
    func testEncodeDecode() async throws {
        // MARK: Encode
        let bgContext = testingUtils.context.newBackgroundContext()
        // TODO: Add Tags
        let sampleData: [(Int, MediaType, StarRating, WatchState, Bool?, String)] = [
            (603, .movie, .threeStars, MovieWatchState.watched, false, "A classic."), // Matrix
            (550, .movie, .noRating, MovieWatchState.notWatched, nil, "Not watched yet."), // Fight Club
            (1399, .show, .threeAndAHalfStars, ShowWatchState.season(8), false, "Not a good ending.\nLine2\n\nLine4"), // Game of Thrones
            (46952, .show, .fiveStars, ShowWatchState.season(7), true, "A great show!,./';\""), // Blacklist
        ]
        var samples: [Media] = []
        let api = TMDBAPI.shared
        for (tmdbID, type, rating, watchState, watchAgain, notes) in sampleData {
            let media = try await api.media(for: tmdbID, type: type, context: bgContext)
            bgContext.performAndWait {
                media.personalRating = rating
                if let watchState = watchState as? MovieWatchState, let movie = media as? Movie {
                    movie.watched = watchState
                } else if let watchState = watchState as? ShowWatchState, let show = media as? Show {
                    show.watched = watchState
                }
                media.watchAgain = watchAgain
                media.notes = notes
            }
            samples.append(media)
        }
        samples.sort(by: \.title)
        
        let exporter = CSVExporter()
        let csv = exporter.createCSV(from: samples)
        XCTAssertEqual(csv.components(separatedBy: .newlines).count, samples.count + 1)
        
        // Wait a bit to ensure that the current time is different from the creationTime of the samples
        try await Task.sleep(for: .seconds(2))
        
        let importer = try CSVImporter(string: csv)
        let mediaObjects = try await importer.decodeMediaObjects(
            importContext: PersistenceController.createDisposableContext()
        )
        XCTAssertEqual(mediaObjects.count, samples.count)
        
        for i in 0..<mediaObjects.count {
            let media = try XCTUnwrap(mediaObjects[i])
            let sample = try XCTUnwrap(samples[i])
            
            XCTAssertNotNil(media.managedObjectContext)
            XCTAssertEqual(media.type, sample.type)
            XCTAssertEqual(media.tmdbID, sample.tmdbID)
            XCTAssertEqual(media.title, sample.title)
            XCTAssertEqual(media.personalRating, sample.personalRating)
            XCTAssertEqual(media.watchAgain, sample.watchAgain)
            XCTAssertEqual(media.tags.map(\.name).sorted(), sample.tags.map(\.name).sorted())
            XCTAssertEqual(media.notes, sample.notes.replacing(/\n+/, with: { _ in " " }))
            XCTAssertEqual(media.originalTitle, sample.originalTitle)
            XCTAssertEqual(media.isAdultMovie, sample.isAdultMovie)
            XCTAssertEqual(media.missingInformation(), sample.missingInformation())
            self.datesEqual(media.creationDate, sample.creationDate)
            self.datesEqual(media.modificationDate, sample.modificationDate)
            
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
    }
    
    // Compares if two dates by comparing their ISO8601 representation
    private func datesEqual(_ date1: Date?, _ date2: Date?) {
        if date1 == nil, date2 == nil {
            // Equal
            return
        }
        guard let date1 else {
            // Will fail with correct error message
            XCTAssertEqual(date1, date2)
            return
        }
        guard let date2 else {
            // Will fail with correct error message
            XCTAssertEqual(date1, date2)
            return
        }
        XCTAssertEqual(isoFormatter.string(from: date1), isoFormatter.string(from: date2))
    }
    
    private func testEncodedMedia(_ data: [CSVKey: String], encodedMedia media: Media) throws {
        let exporter = CSVExporter()
        // data[key] never returns nil, since every value is read from CSV and nil-values in CSV are empty strings
        // If data[key] returns nil, that means, that the CSV value was never read/written and therefore is a bug in the CSVCoder!
        XCTAssertEqual(data[.id], media.id?.uuidString)
        XCTAssertEqual(data[.mediaType], media.type.rawValue)
        XCTAssertEqual(data[.personalRating], media.personalRating.rawValue.description)
        let tagNames = media.tags.map(\.name)
        XCTAssertEqual(data[.tags], tagNames.sorted().joined(separator: exporter.arraySeparator))
        // data[key] always returns a string, so we have to map the boolean to its csv-representation (nil == "")
        XCTAssertEqual(data[.watchAgain], media.watchAgain?.description ?? "")
        XCTAssertEqual(data[.notes], media.notes)
        
        XCTAssertEqual(data[.tmdbID], media.tmdbID.description)
        XCTAssertEqual(data[.title], media.title)
        XCTAssertEqual(data[.originalTitle], media.originalTitle)
        let genreNames = media.genres.map(\.name)
        XCTAssertEqual(data[.genres], genreNames.sorted().joined(separator: exporter.arraySeparator))
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
                XCTAssertEqual(data[.releaseDate], exporter.dateFormatter.string(from: releaseDate))
            } else {
                XCTAssertEqual(data[.releaseDate], "")
            }
            XCTAssertEqual(data[.runtime], movie.runtime?.description ?? "")
            XCTAssertEqual(data[.budget], movie.budget.description)
            XCTAssertEqual(data[.revenue], movie.revenue.description)
            XCTAssertEqual(data[.isAdult], movie.isAdult.description)
        } else if let show = media as? Show {
            // Show exclusive
            XCTAssertEqual(data[.lastSeasonWatched], show.watched?.season.description ?? "")
            XCTAssertEqual(data[.lastEpisodeWatched], show.watched?.episode?.description ?? "")
            if let firstAirDate = show.firstAirDate {
                XCTAssertEqual(data[.firstAirDate], exporter.dateFormatter.string(from: firstAirDate))
            } else {
                XCTAssertEqual(data[.firstAirDate], "")
            }
            if let lastAirDate = show.lastAirDate {
                XCTAssertEqual(data[.lastAirDate], exporter.dateFormatter.string(from: lastAirDate))
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
        let exporter = CSVExporter()
        let media1 = testingUtils.matrixMovie // Statically loaded from JSON
        let newName = "Illegal\(exporter.separator) Tag"
        let tagWithSeparator = Tag(name: newName, context: testingUtils.context)
        media1.tags.insert(tagWithSeparator)
        media1.notes = "This note contains:\(exporter.separator)\(exporter.arraySeparator)"
        let media2 = testingUtils.fightClubMovie
        media2.notes = "This note contains:\nnewlines"
        let csv = exporter.createCSV(from: [media1, media2])
        let lines = csv.components(separatedBy: exporter.lineSeparator)
        // Additional line for the header and the line break in the note
        XCTAssertEqual(lines.count, 3)
        // Fields with illegal characters in the CSV output will be encased in quotation marks
        XCTAssertEqual(lines[1], "603;movie;5;false;\"Conspiracy,Dark,Future,Illegal; Tag\";\"This note contains:;,\";watched;;;\(media1.id?.uuidString ?? "");Welcome to the Real World.;The Matrix;The Matrix;Action,Science Fiction;Set in the 22nd century, The Matrix tells the story of a computer hacker who joins a group of underground insurgents fighting the vast and powerful computers who now rule the earth.;Released;1999-03-30;136;63000000;463517383;false;;;;;;;\(exporter.dateTimeFormatter.string(from: media1.creationDate));\(media1.modificationDate.map { exporter.dateTimeFormatter.string(from: $0) } ?? "")")
        XCTAssertEqual(lines[2], "550;movie;0;;Dark,Violent;This note contains: newlines;notWatched;;;\(media2.id?.uuidString ?? "");Mischief. Mayhem. Soap.;Fight Club;Fight Club;Drama;A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground \"\"fight clubs\"\" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.;Released;1999-10-15;139;63000000;100853753;false;;;;;;;\(exporter.dateTimeFormatter.string(from: media2.creationDate));\(media2.modificationDate.map { exporter.dateTimeFormatter.string(from: $0) } ?? "")")
    }
}
