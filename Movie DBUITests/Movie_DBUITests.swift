//
//  Movie_DBUITests.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import XCTest

// swiftlint:disable implicitly_unwrapped_optional multiline_function_chains inclusive_language function_body_length
class Movie_DBUITests: XCTestCase {
    var app: XCUIApplication! = nil
    
    var libraryNavBar: XCUIElement {
        app.navigationBars["Library"]
    }
    var addMediaNavBar: XCUIElement {
        app.navigationBars["Add Media"]
    }
    var addMediaButton: XCUIElement {
        libraryNavBar.buttons["add-media"]
    }
    var addMediaSearch: XCUIElement {
        addMediaNavBar.searchFields.firstMatch
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app = nil
    }
    
    func testAddMovie() {
        app.launch()
        addMedia("Matrix", name: "The Matrix, Movie")
        // Matrix should be in the library now
        XCTAssertTrue(app.tables.cells["The Matrix, 1999"].waitForExistence(timeout: 10))
    }
    
    func testAddShow() {
        app.launch()
        addMedia("Blacklist", name: "The Blacklist, Series")
        // Matrix should be in the library now
        XCTAssertTrue(app.tables.cells["The Blacklist, 2013"].waitForExistence(timeout: 10))
    }
    
    func testAddTwice() {
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
    
    func testAddAndRemove() {
        app.launch()
        addMatrix()
        XCTAssertTrue(app.tables.cells["The Matrix, 1999"].wait().exists)
        // Delete the new movie
        app.tables.cells["The Matrix, 1999"]
            .swipeLeft()
        app.tables.cells["The Matrix, 1999"].buttons["Delete"]
            .wait()
            .tap()
        // Should not exist anymore
        XCTAssertFalse(app.tables.cells["The Matrix, 1999"].exists)
    }
    
    func testShowMovieDetail() {
        app.launch()
        addMatrix()
        app.tables.cells["The Matrix, 1999"]
            .wait()
            .tap()
        // Title cell
        app.tables.cells["The Matrix, 1999"].tap()
        let detailBackButton = app.navigationBars.element.buttons.firstMatch
        detailBackButton.tap()
        app.tables.cells
            .first(hasPrefix: "Description")
            .tap()
        detailBackButton.tap()
        app.tables.cells["Cast"].tap()
        // Give the cast page a bit of time to load
        wait()
        detailBackButton.tap()
    }
    
    func testShowShowDetail() {
        app.launch()
        addBlacklist()
        app.tables.cells["The Blacklist, 2013"]
            .wait()
            .tap()
        // Title cell
        app.tables.cells["The Blacklist, 2013"].tap()
        let detailBackButton = app.navigationBars.element.buttons.firstMatch
        detailBackButton.tap()
        app.tables.cells
            .first(hasPrefix: "Description")
            .tap()
        detailBackButton.tap()
        app.tables.cells
            .first(hasPrefix: "Seasons")
            .tap()
        wait()
        detailBackButton.tap()
        
        app.tables.cells["Cast"].tap()
        // Give the cast page a bit of time to load
        wait()
        detailBackButton.tap()
    }
    
    func testEditShowDetail() {
        app.launch()
        addBlacklist()
        app.tables.cells["The Blacklist, 2013"]
            .wait()
            .tap()
        // Go into edit mode
        app.navigationBars.element.buttons["Edit"].tap()
        
        app.tables.cells
            .first(hasPrefix: "Personal Rating")
            .buttons["Increment"]
            .tap(withNumberOfTaps: 7, numberOfTouches: 1)
        
        app.tables.cells
            .first(hasPrefix: "Watched?")
            .staticTexts
            .element(boundBy: 1)
            .tap()
        app.steppers.element.buttons["Increment"]
            .tap(withNumberOfTaps: 3, numberOfTouches: 1)
        app.steppers.element(boundBy: 1).buttons["Increment"]
            .tap(withNumberOfTaps: 10, numberOfTouches: 1)
        app.steppers.element(boundBy: 1).buttons["Increment"]
            .tap(withNumberOfTaps: 5, numberOfTouches: 1)
        goBack()
        
        app.tables.cells
            .first(hasPrefix: "Watch again?")
            .buttons["No"]
            .tap()
        
        app.tables.cells
            .first(hasPrefix: "Tags")
            .staticTexts
            .element(boundBy: 1)
            .tap()
        // Create tags
        func addTag(_ name: String) {
            let navBar = app.navigationBars["Tags"]
            navBar.buttons["Add"].tap()
            app.textFields.element.typeText(name)
            app.alerts.buttons["Add"].tap()
        }
        
        addTag("Tag1!")
        addTag("Tag 2")
        addTag("Tag~3.test")
        
        app.tables.cells.first(hasPrefix: "Tag1!").tap()
        app.tables.cells.first(hasPrefix: "Tag~3.test").tap()
        
        // Modify
        goBack()
        
        app.tables.cells
            .first(hasPrefix: "Notes")
            .staticTexts
            .element(boundBy: 1)
            .tap()
        // Modify
        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("This is a sample note.\nDone.")
        goBack()
        
        // Stop Editing
        app.navigationBars.element.buttons["Done"].tap()
        
        // Assertions
        XCTAssertEqual(
            app.tables.cells.first(hasPrefix: "Personal Rating").label,
            "Personal Rating, Favorite, Favorite, Favorite, Half Star, Favorite"
        )
        XCTAssertEqual(
            app.tables.cells.first(hasPrefix: "Watched?").label,
            "Watched?, Season 3, Episode 15"
        )
        XCTAssertEqual(
            app.tables.cells.first(hasPrefix: "Watch again?").label,
            "Watch again?, No"
        )
        XCTAssertEqual(
            app.tables.cells.first(hasPrefix: "Tags").label,
            "Tags, Tag1!, Tag~3.test"
        )
        XCTAssertEqual(
            app.tables.cells.first(hasPrefix: "Notes").label,
            "Notes, This is a sample note.\nDone."
        )
        goBack()
    }
    
    func disabled_testFilter() {
        // Add and configure Blacklist
        testEditShowDetail()
        // TODO: Test filter
        // Implement after reworking the filter UI
    }
    
    func testSearch() {
        app.launch()
        
        addMatrix()
        XCTAssertTrue(app.tables.cells["The Matrix, 1999"].waitForExistence(timeout: 10))
        
        // We need to scroll a bit to fix the add button not being hittable
        app.swipeUp()
        XCTAssertTrue(addMediaButton.waitForHittable(app).isHittable)
        
        addBlacklist()
        XCTAssertTrue(app.tables.cells["The Blacklist, 2013"].waitForExistence(timeout: 10))
        
        // Search for 'Blacklist'
        libraryNavBar.searchFields.element.wait().tap()
        libraryNavBar.searchFields.element.typeText("Blacklist")
        
        // Check results
        XCTAssertEqual(app.tables.cells.count, 1)
        XCTAssertEqual(app.tables.cells.element.label, "The Blacklist, 2013")
    }
    
    // TODO: UI Tests for settings
    
    func goBack() {
        app.navigationBars.element.buttons.firstMatch.tap()
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
    
    func wait(_ timeout: TimeInterval = 1) {
        XCTAssertFalse(app.wait(for: .runningBackground, timeout: timeout))
    }
}

extension XCUIElementQuery {
    func first(where key: String = "label", hasPrefix prefix: String) -> XCUIElement {
        self.matching(NSPredicate(format: "%K BEGINSWITH %@", key, prefix)).firstMatch
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
