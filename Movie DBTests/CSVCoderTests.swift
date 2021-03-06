//
//  CSVCoderTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 03.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import XCTest
@testable import Movie_DB

class CSVCoderTests: XCTestCase {
    
    var csvCoder: CSVCoder!
    
    override func setUp() {
        csvCoder = CSVCoder()
    }
    
    override func tearDown() {
        csvCoder = nil
    }
    
    func testDecode() throws {
        let sample1 = """
        id;tmdb_id;type;title;personal_rating;watch_again;tags;notes;original_title;genres;overview;status;watched;release_date;runtime;budget;revenue;is_adult;last_episode_watched;first_air_date;last_air_date;number_of_seasons;is_in_production;show_type
        113;346808;movie;Momentum;8;true;Female Lead,Gangsters,Kidnapping,Revenge;;Momentum;Action,Thriller;When Alex, an infiltration expert with a secret past, accidentally reveals her identity during what should have been a routine heist, she quickly finds herself mixed up in a government conspiracy and entangled in a deadly game of cat-and-mouse with a master assassin and his team of killers.  Armed with her own set of lethal skills, Alex looks to exact revenge for her murdered friends while uncovering the truth.;Released;true;2015-08-01;96;20000000;133332;false;;;;;;
        157;75219;tv;9-1-1;2;true;Crime;A very great series;9-1-1;Drama,Action & Adventure,Crime;Explore the high-pressure experiences of police officers, paramedics and firefighters who are thrust into the most frightening, shocking and heart-stopping situations. These emergency responders must try to balance saving those who are at their most vulnerable with solving the problems in their own lives.;Returning Series;;;;;;;3;2018-01-03;2020-05-11;3;true;Scripted
        125;79130;tv;Another Life;1;false;Artificial Intelligence,Aliens,Female Lead,Haunted,Future,Horror,Space,Extinction Level Event;;Another Life;Drama,Sci-Fi & Fantasy;After a massive alien artifact lands on Earth, Niko Breckinridge leads an interstellar mission to track down its source and make first contact.;Returning Series;;;;;;;3/5;2019-07-25;2019-07-25;1;true;Scripted
        116;399402;movie;Hunter Killer;0;false;;A note with some special characters.\\/:?!;Hunter Killer;Action,Thriller;;Released;true;2018-10-19;122;0;0;false;;;;;;
        """
        let mediaObjects = try csvCoder.decode(sample1)
        XCTAssertEqual(mediaObjects.count, 4)
        
        // MARK: Momentum
        XCTAssertEqual(mediaObjects[0].type, .movie)
        let momentum = try XCTUnwrap(mediaObjects[0] as? Movie)
        try testDecodeMomentum(momentum)
        
        // MARK: 9-1-1
        XCTAssertEqual(mediaObjects[1].type, .show)
        let nineOneOne = try XCTUnwrap(mediaObjects[1] as? Show)
        try testDecodeNineOneOne(nineOneOne)
        
        // MARK: Another Life
        XCTAssertEqual(mediaObjects[2].type, .show)
        let anotherLife = try XCTUnwrap(mediaObjects[2] as? Show)
        try testDecodeAnotherLife(anotherLife)
        
        // MARK: Hunter Killer
        XCTAssertEqual(mediaObjects[3].type, .movie)
        let hunterKiller = try XCTUnwrap(mediaObjects[3] as? Movie)
        try testDecodeHunterKiller(hunterKiller)
    }
    
    private func testDecodeMomentum(_ media: Movie) throws {
        // The ID has not to be the same, as in the CSV. The ID will be re-issued
        XCTAssertGreaterThan(media.id, 0)
        XCTAssertEqual(media.tmdbData?.id, 346808)
        XCTAssertEqual(media.tmdbData?.title, "Momentum")
        XCTAssertEqual(media.personalRating, .fourStars)
        XCTAssertEqual(media.watchAgain, true)
        XCTAssertEqual(media.tags.map(TagLibrary.shared.name(for:)), ["Female Lead", "Gangsters", "Kidnapping", "Revenge"])
        XCTAssertEqual(media.notes, "")
        // TMDBData will be re-fetched from the API, so the data could be different, than the data in the CSV
        let momentumTMDBData = try XCTUnwrap(media.tmdbData)
        XCTAssertTrue(type(of: momentumTMDBData) == TMDBMovieData.self)
        XCTAssertEqual(media.tmdbData?.originalTitle, "Momentum")
        XCTAssertEqual((momentumTMDBData as? TMDBMovieData)?.isAdult, false)
        
        XCTAssertEqual(media.watched, true)
        XCTAssertEqual(media.missingInformation, Set<Media.MediaInformation>())
    }
    
    private func testDecodeNineOneOne(_ media: Show) throws {
        // The ID has not to be the same, as in the CSV. The ID will be re-issued
        XCTAssertGreaterThan(media.id, 0)
        XCTAssertEqual(media.tmdbData?.id, 75219)
        XCTAssertEqual(media.tmdbData?.title, "9-1-1")
        XCTAssertEqual(media.personalRating, .oneStar)
        XCTAssertEqual(media.watchAgain, true)
        XCTAssertEqual(media.tags.map(TagLibrary.shared.name(for:)), ["Crime"])
        XCTAssertEqual(media.notes, "A very great series")
        // TMDBData will be re-fetched from the API, so the data could be different, than the data in the CSV
        let momentumTMDBData = try XCTUnwrap(media.tmdbData)
        XCTAssertTrue(type(of: momentumTMDBData) == TMDBShowData.self)
        XCTAssertEqual(media.tmdbData?.originalTitle, "9-1-1")
        XCTAssertEqual((momentumTMDBData as? TMDBShowData)?.type, .scripted)
        
        XCTAssertEqual(media.lastWatched, .init(season: 3))
        XCTAssertEqual(media.missingInformation, Set<Media.MediaInformation>())
    }
    
    private func testDecodeAnotherLife(_ media: Show) throws {
        // The ID has not to be the same, as in the CSV. The ID will be re-issued
        XCTAssertGreaterThan(media.id, 0)
        XCTAssertEqual(media.tmdbData?.id, 79130)
        XCTAssertEqual(media.tmdbData?.title, "Another Life")
        XCTAssertEqual(media.personalRating, .halfStar)
        XCTAssertEqual(media.watchAgain, false)
        XCTAssertEqual(media.tags.map(TagLibrary.shared.name(for:)), ["Artificial Intelligence", "Aliens", "Female Lead", "Haunted", "Future", "Horror", "Space", "Extinction Level Event"])
        XCTAssertEqual(media.notes, "")
        // TMDBData will be re-fetched from the API, so the data could be different, than the data in the CSV
        let momentumTMDBData = try XCTUnwrap(media.tmdbData)
        XCTAssertTrue(type(of: momentumTMDBData) == TMDBShowData.self)
        XCTAssertEqual(media.tmdbData?.originalTitle, "Another Life")
        XCTAssertEqual((momentumTMDBData as? TMDBShowData)?.type, .scripted)
        
        XCTAssertEqual(media.lastWatched, .init(season: 3, episode: 5))
        XCTAssertEqual(media.missingInformation, Set<Media.MediaInformation>())
    }
    
    private func testDecodeHunterKiller(_ media: Movie) throws {
        // The ID has not to be the same, as in the CSV. The ID will be re-issued
        XCTAssertGreaterThan(media.id, 0)
        XCTAssertEqual(media.tmdbData?.id, 399402)
        XCTAssertEqual(media.tmdbData?.title, "Hunter Killer")
        XCTAssertEqual(media.personalRating, .noRating)
        XCTAssertEqual(media.watchAgain, false)
        XCTAssertEqual(media.tags, [])
        XCTAssertEqual(media.notes, "A note with some special characters.\\/:?!")
        // TMDBData will be re-fetched from the API, so the data could be different, than the data in the CSV
        XCTAssertNotEqual(media.tmdbData?.overview, "")
        let momentumTMDBData = try XCTUnwrap(media.tmdbData)
        XCTAssertTrue(type(of: momentumTMDBData) == TMDBMovieData.self)
        XCTAssertEqual(media.tmdbData?.originalTitle, "Hunter Killer")
        XCTAssertEqual((momentumTMDBData as? TMDBMovieData)?.isAdult, false)
        
        XCTAssertEqual(media.watched, true)
        XCTAssertEqual(media.missingInformation, Set<Media.MediaInformation>([.rating, .tags]))
    }
    
    func testEncode() throws {
        let csv = try csvCoder.encode(TestingUtils.mediaSamples)
        let lines = csv.components(separatedBy: csvCoder.lineSeparator)
        // We should get an extra line for the header
        XCTAssertEqual(lines.count, TestingUtils.mediaSamples.count + 1)
        
        // MARK: Header
        let csvHeaders = lines.first!.components(separatedBy: csvCoder.separator)
        XCTAssertEqual(csvHeaders.count, csvCoder.headers.count)
        for i in 0..<csvCoder.headers.count {
            let header = csvCoder.headers[i]
            let csvHeader = csvHeaders[i]
            XCTAssertEqual(header.rawValue, csvHeader)
        }
        
        // Map the values to their headers to make a dictionary
        let components: [[String]] = lines.dropFirst().map({ $0.components(separatedBy: csvCoder.separator) })
        var dictionaries: [[CSVCodingKey: String]] = []
        for line in components {
            XCTAssertEqual(line.count, csvCoder.headers.count)
            let pairs = (0..<csvCoder.headers.count).map { i -> (CSVCodingKey, String) in
                let header = csvCoder.headers[i]
                let value = line[i]
                return (header, value)
            }
            dictionaries.append(Dictionary(uniqueKeysWithValues: pairs))
        }
        
        // We have to match the media object with their CSV line, as they all get sorted when exported
        let sortedSamples = TestingUtils.mediaSamples.sorted(by: { (media1, media2) in
            // Sort nil before real values
            guard let tmdbData1 = media1.tmdbData else {
                return true
            }
            guard let tmdbData2 = media2.tmdbData else {
                return false
            }
            return tmdbData1.title.lexicographicallyPrecedes(tmdbData2.title)
        })
        // Test all sample media objects
        for i in 0..<TestingUtils.mediaSamples.count {
            try testEncodedMedia(dictionaries[i], encodedMedia: sortedSamples[i])
        }
    }
    
    private func testEncodedMedia(_ data: [CSVCodingKey: String], encodedMedia media: Media) throws {
        // data[key] never returns nil, since every value is read from CSV and nil-values in CSV are empty strings
        // If data[key] returns nil, that means, that the CSV value was never read/written and therefore is a bug in the CSVCoder!
        XCTAssertEqual(data[.id], media.id.description)
        XCTAssertEqual(data[.type], media.type.rawValue)
        XCTAssertEqual(data[.personalRating], media.personalRating.rawValue.description)
        let tagNames = try media.tags.map({ try XCTUnwrap(TagLibrary.shared.name(for: $0)) })
        XCTAssertEqual(data[.tags], tagNames.joined(separator: csvCoder.arraySeparator))
        // data[key] always returns a string, so we have to map the boolean to its csv-representation (nil == "")
        XCTAssertEqual(data[.watchAgain], media.watchAgain?.description ?? "")
        XCTAssertEqual(data[.notes], media.notes)
        
        XCTAssertEqual(data[.tmdbID], media.tmdbData?.id.description ?? "")
        XCTAssertEqual(data[.title], media.tmdbData?.title ?? "")
        XCTAssertEqual(data[.originalTitle], media.tmdbData?.originalTitle ?? "")
        let genreNames = media.tmdbData?.genres.map(\.name)
        XCTAssertEqual(data[.genres], genreNames?.joined(separator: csvCoder.arraySeparator) ?? "")
        XCTAssertEqual(data[.overview], media.tmdbData?.overview ?? "")
        XCTAssertEqual(data[.status], media.tmdbData?.status.rawValue ?? "")
        
        // Movie exclusive
        let movie = media as? Movie
        let tmdbMovieData = media.tmdbData as? TMDBMovieData
        if movie == nil {
            XCTAssertNil(tmdbMovieData)
        } else {
            XCTAssertNotNil(tmdbMovieData)
        }
        XCTAssertEqual(data[.watched], movie?.watched?.description ?? "")
        if let releaseDate = tmdbMovieData?.releaseDate {
            XCTAssertEqual(data[.releaseDate], csvCoder.dateFormatter.string(from: releaseDate))
        } else {
            XCTAssertEqual(data[.releaseDate], "")
        }
        XCTAssertEqual(data[.runtime], tmdbMovieData?.runtime?.description ?? "")
        XCTAssertEqual(data[.budget], tmdbMovieData?.budget.description ?? "")
        XCTAssertEqual(data[.revenue], tmdbMovieData?.revenue.description ?? "")
        XCTAssertEqual(data[.isAdult], tmdbMovieData?.isAdult.description ?? "")
        
        // Show exclusive
        let show = media as? Show
        let tmdbShowData = media.tmdbData as? TMDBShowData
        if show == nil {
            XCTAssertNil(tmdbShowData)
        } else {
            XCTAssertNotNil(tmdbShowData)
        }
        XCTAssertEqual(data[.lastWatched], show?.lastWatched?.description ?? "")
        if let firstAirDate = tmdbShowData?.firstAirDate {
            XCTAssertEqual(data[.firstAirDate], csvCoder.dateFormatter.string(from: firstAirDate))
        } else {
            XCTAssertEqual(data[.firstAirDate], "")
        }
        if let lastAirDate = tmdbShowData?.lastAirDate {
            XCTAssertEqual(data[.lastAirDate], csvCoder.dateFormatter.string(from: lastAirDate))
        } else {
            XCTAssertEqual(data[.lastAirDate], "")
        }
        XCTAssertEqual(data[.numberOfSeasons], tmdbShowData?.numberOfSeasons?.description ?? "")
        XCTAssertEqual(data[.isInProduction], tmdbShowData?.isInProduction.description ?? "")
        XCTAssertEqual(data[.showType], tmdbShowData?.type?.rawValue ?? "")
    }
    
    func testEncodeMediaWithIllegalCharacters() throws {
        let media = TestingUtils.matrixMovie
        let newName = "Illegal\(csvCoder.separator) Tag"
        var tagWithSeparator = TagLibrary.shared.tags.first(where: { $0.name == newName })?.id
        if tagWithSeparator == nil {
            tagWithSeparator = TagLibrary.shared.create(name: newName)
        }
        media.tags.append(tagWithSeparator!)
        media.notes = "This note contains:\(csvCoder.lineSeparator)\(csvCoder.separator)\(csvCoder.arraySeparator)"
        csvCoder.headers = [.tmdbID, .title, .tags, .notes, .type]
        let csv = try csvCoder.encode([media])
        let lines = csv.components(separatedBy: csvCoder.lineSeparator)
        XCTAssertEqual(lines.count, 2)
        XCTAssertEqual(lines[0], "tmdb_id\(csvCoder.separator)title\(csvCoder.separator)tags\(csvCoder.separator)notes\(csvCoder.separator)type")
        // The illegal characters should have been removed in the CSV output (arraySeparator should remain, since the note is not an array)
        XCTAssertEqual(lines[1], "603\(csvCoder.separator)The Matrix\(csvCoder.separator)Future\(csvCoder.arraySeparator)Conspiracy\(csvCoder.arraySeparator)Dark\(csvCoder.arraySeparator)Illegal Tag\(csvCoder.separator)This note contains:\(csvCoder.arraySeparator)\(csvCoder.separator)movie")
    }

}
