//
//  CoreDataTests.swift
//  Movie DBTests
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

import CoreData
@testable import Movie_DB
import XCTest

class CoreDataTests: XCTestCase {
    var testingUtils: TestingUtils!
    var testContext: NSManagedObjectContext {
        testingUtils.context
    }
    
    var matrix: TMDBData!
    var fightClub: TMDBData!
    // swiftlint:disable:next inclusive_language
    var blacklist: TMDBData!
    var gameOfThrones: TMDBData!
    var brokenMedia: Movie!
    
    override func setUp() {
        super.setUp()
        testingUtils = TestingUtils()
        matrix = TestingUtils.load("Matrix.json", mediaType: .movie, into: testContext)
        fightClub = TestingUtils.load("FightClub.json", mediaType: .movie, into: testContext)
        blacklist = TestingUtils.load("Blacklist.json", mediaType: .show, into: testContext)
        gameOfThrones = TestingUtils.load("GameOfThrones.json", mediaType: .show, into: testContext)
        brokenMedia = {
            let movie = Movie(
                context: testContext,
                tmdbData: TestingUtils.load("Matrix.json", mediaType: .movie, into: testContext)
            )
            movie.tmdbID = -1
            return movie
        }()
    }
    
    override func tearDown() {
        super.tearDown()
        testingUtils = nil
        matrix = nil
        fightClub = nil
        blacklist = nil
        gameOfThrones = nil
        brokenMedia = nil
    }
    
    func testPredicate() throws {
        let allFetch: NSFetchRequest<Media> = Media.fetchRequest()
        let allMedia = try testContext.fetch(allFetch)
        print("All media in context: \(allMedia.map(\.tmdbID))")
        let existingFetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        existingFetchRequest.predicate = NSPredicate(format: "%K = %@", "tmdbID", NSNumber(603))
        XCTAssertEqual(try testContext.fetch(existingFetchRequest).count, 1)
    }
    
    func testSaveContext() throws {
        try testContext.save()
    }
    
    func testSaveChildContext() throws {
        try testContext.newBackgroundContext().save()
    }
    
    func testAutocreateGenres() throws {
        func allGenres() -> [Genre] {
            try! testContext.fetch(Genre.fetchRequest())
        }
        
        testContext.reset()
        // Add a movie with genres
        _ = Movie(context: testContext, genres: [
            GenreDummy(id: 1, name: "Genre 1"),
            GenreDummy(id: 2, name: "Genre 2"),
            GenreDummy(id: 3, name: "Genre 3")
        ])
        XCTAssertEqual(allGenres().count, 3)
        
        // Add another movie with overlapping genres
        _ = Movie(context: testContext, genres: [
                GenreDummy(id: 2, name: "Genre 2"),
                GenreDummy(id: 3, name: "Genre 3"),
                GenreDummy(id: 4, name: "Genre 4")
        ])
        
        // We only should have one new genre (Genre 4)
        XCTAssertEqual(allGenres().count, 4)
    }
}
