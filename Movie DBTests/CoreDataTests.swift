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

final class CoreDataTests: XCTestCase {
    var testContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        testContext = PersistenceController.createTestingContext()
    }

    override func tearDown() {
        testContext = nil
        super.tearDown()
    }

    func testMediaLibraryMediaExistsUsesMediaType() {
        _ = Movie(context: testContext, id: 603, title: "The Matrix")
        let library = MediaLibrary(context: testContext)

        XCTAssertTrue(library.mediaExists(603, mediaType: .movie, in: testContext))
        XCTAssertFalse(library.mediaExists(603, mediaType: .show, in: testContext))
        XCTAssertFalse(library.mediaExists(-1, mediaType: .movie, in: testContext))
    }

    func testMediaLibraryProblemsDetectsDuplicateTMDBIDs() throws {
        let first = Movie(context: testContext, id: 603, title: "Duplicate A")
        let second = Movie(context: testContext, id: 603, title: "Duplicate B")
        try testContext.save()
        testContext.processPendingChanges()

        let problems = MediaLibrary(context: testContext).problems()

        XCTAssertEqual(problems.count, 1)
        XCTAssertEqual(problems.first?.associatedMedias.count, 2)
        XCTAssertEqual(Set(problems.first?.associatedMedias.map(\.tmdbID) ?? []), [603])
        XCTAssertEqual(Set(problems.first?.associatedMedias.map(\.objectID) ?? []), [first.objectID, second.objectID])
    }

    func testMediaLibraryCleanupDeletesUnusedGenres() throws {
        _ = Movie(context: testContext, genres: [
            GenreDummy(id: 1, name: "Used Genre")
        ])
        let orphanGenre = Genre(context: testContext)
        orphanGenre.id = 2
        orphanGenre.name = "Orphan Genre"

        try MediaLibrary(context: testContext).cleanup()

        let remainingGenres = try testContext.fetch(Genre.fetchRequest())
        XCTAssertEqual(Set(remainingGenres.map(\.name)), ["Used Genre"])
    }

    func testMediaLibraryResetTagsDeletesTagsFromLibrary() async throws {
        let tag1 = Tag(name: "Action", context: testContext)
        let tag2 = Tag(name: "Drama", context: testContext)
        let movie = Movie(context: testContext, id: 603, title: "Tagged Movie")
        movie.tags = [tag1, tag2]
        XCTAssertEqual(try testContext.fetch(Tag.fetchRequest()).count, 2)

        try await MediaLibrary(context: testContext).resetTags()

        XCTAssertEqual(try testContext.fetch(Tag.fetchRequest()).count, 0)
        XCTAssertTrue(movie.tags.isEmpty)
    }

    func testAutocreateGenres() throws {
        func allGenres() -> [Genre] {
            try! testContext.fetch(Genre.fetchRequest())
        }

        _ = Movie(context: testContext, genres: [
            GenreDummy(id: 1, name: "Genre 1"),
            GenreDummy(id: 2, name: "Genre 2"),
            GenreDummy(id: 3, name: "Genre 3")
        ])
        XCTAssertEqual(allGenres().count, 3)

        _ = Movie(context: testContext, genres: [
            GenreDummy(id: 2, name: "Genre 2"),
            GenreDummy(id: 3, name: "Genre 3"),
            GenreDummy(id: 4, name: "Genre 4")
        ])

        XCTAssertEqual(allGenres().count, 4)
    }
}
