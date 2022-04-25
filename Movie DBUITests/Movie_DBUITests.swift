//
//  Movie_DBUITests.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import XCTest
@testable import Movie_DB
import CoreData

// swiftlint:disable implicitly_unwrapped_optional multiline_function_chains inclusive_language
class Movie_DBUITests: XCTestCase {
    var app: XCUIApplication! = nil
    
    var libraryNavBar: XCUIElement!
    var addMediaNavBar: XCUIElement!
    var addMediaButton: XCUIElement!
    var addMediaSearch: XCUIElement!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launchEnvironment = ["animations": "0"]
        UIView.setAnimationsEnabled(false)
        
        libraryNavBar = app.navigationBars["Library"]
        addMediaNavBar = app.navigationBars["Add Media"]
        addMediaButton = libraryNavBar.buttons["add-media"]
        addMediaSearch = addMediaNavBar.searchFields.firstMatch
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app = nil
        
        libraryNavBar = nil
        addMediaNavBar = nil
        addMediaButton = nil
        addMediaSearch = nil
    }
    
    func testAddMovie() throws {
        app.launch()
        addMedia("Matrix", name: "The Matrix, Movie")
        // Matrix should be in the library now
        XCTAssertTrue(app.tables.cells["The Matrix, 1999"].waitForExistence(timeout: 10))
    }
    
    func testAddShow() throws {
        app.launch()
        addMedia("Blacklist", name: "The Blacklist, Series")
        // Matrix should be in the library now
        XCTAssertTrue(app.tables.cells["The Blacklist, 2013"].waitForExistence(timeout: 10))
    }
    
    func testAddTwice() throws {
        app.launch()
        addMedia("Matrix", name: "The Matrix, Movie")
        // Wait until the first movie has been added
        XCTAssertTrue(app.tables.cells["The Matrix, 1999"].waitForExistence(timeout: 10))
        // We need to scroll a bit to fix the add button not being hittable
        app.swipeUp()
        XCTAssertTrue(addMediaButton.waitForHittable(app).isHittable)
        // Add it again
        addMedia("Matrix", name: "The Matrix, Movie")
        // Now we should have been displayed the error
        XCTAssertEqual(app.alerts.element.label, "Already Added")
    }
    
    func testAddAndRemove() throws {
        app.launch()
        addMatrix()
        XCTAssertTrue(app.tables.cells["The Matrix, 1999"].wait().exists)
//        addBlacklist()
//        XCTAssertTrue(app.tables.cells["The Blacklist, 2013"].wait().exists)
        // Delete the new movie
        app.tables.cells["The Matrix, 1999"]
            .swipeLeft()
        app.tables.cells["The Matrix, 1999"].buttons["Delete"]
            .wait()
            .tap()
        // Should not exist anymore
        XCTAssertFalse(app.tables.cells["The Matrix, 1999"].exists)
    }
    
    func addMatrix() {
        addMedia("Matrix", name: "The Matrix, Movie")
    }
    
    func addBlacklist() {
        addMedia("Blacklist", name: "The Blacklist, Series")
    }
    
    func addMedia(_ query: String, name: String) {
        addMediaButton.tap()
        addMediaSearch.tap()
        addMediaSearch.typeText("\(query)\n")
        XCTAssertTrue(app.tables.cells[name].waitForExistence(timeout: 10))
        app.tables.cells[name].tap()
    }
}

extension XCUIElement {
    func wait() -> XCUIElement {
        XCTAssertTrue(self.waitForExistence(timeout: 5))
        return self
    }
    
    func waitForHittable(_ app: XCUIApplication, timeout: TimeInterval = 5.0) -> XCUIElement {
        var waited: TimeInterval = 0
        while waited < timeout {
            guard !isHittable else {
                return self
            }
            // We should not actually go into background. We just use this function to wait
            XCTAssertFalse(app.wait(for: .runningBackground, timeout: 0.5))
            waited += 0.5
        }
        return self
    }
}
