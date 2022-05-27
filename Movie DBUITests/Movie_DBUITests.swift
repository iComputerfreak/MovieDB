//
//  Movie_DBUITests.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import XCTest

// swiftlint:disable implicitly_unwrapped_optional multiline_function_chains inclusive_language function_body_length type_body_length file_length
class Movie_DBUITests: XCTestCase {
    var isSetup = false
    
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
    
    var tabBar: XCUIElementQuery {
        app.tabBars.element.buttons
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        
        if !isSetup {
            app.launch()
            if app.navigationBars.firstMatch.staticTexts.firstMatch.label == "Select Language" {
                app.cells["English (United States)"].tap()
                app.buttons["Settings"].tap()
                app.cells.first(hasPrefix: "Region").tap()
                app.cells["Germany"].tap()
            }
            isSetup = true
        }
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app = nil
    }
    
    func testAddMovie() {
        app.launch()
        addMedia("Matrix", name: "The Matrix", type: .movie)
    }
    
    func testAddShow() {
        app.launch()
        addMedia("Blacklist", name: "The Blacklist", type: .show)
    }
    
    func testAddTwice() {
        app.launch()
        addMatrix()
        // We need to scroll a bit to fix the add button not being hittable
        app.swipeUp()
        XCTAssertTrue(addMediaButton.waitForHittable(app).isHittable)
        // Add it again
        addMatrix(checkAdded: false)
        // Now we should have been displayed the error
        XCTAssertEqual(app.alerts.element.label, "Already Added")
    }
    
    func testAddAndRemove() {
        app.launch()
        addMatrix()
        // Delete the new movie
        app.tables.cells.first(hasPrefix: "The Matrix,")
            .swipeLeft()
        app.tables.cells.first(hasPrefix: "The Matrix,").buttons["Delete"]
            .wait()
            .tap()
        // Should not exist anymore
        XCTAssertFalse(app.tables.cells.first(hasPrefix: "The Matrix,").exists)
    }
    
    func testShowMovieDetail() {
        app.launch()
        addMatrix()
        app.tables.cells.first(hasPrefix: "The Matrix,")
            .wait()
            .tap()
        // Title cell
        app.tables.cells.first(hasPrefix: "The Matrix,").tap()
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
        app.tables.cells.first(hasPrefix: "The Blacklist,")
            .wait()
            .tap()
        // Title cell
        app.tables.cells.first(hasPrefix: "The Blacklist,").tap()
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
        app.tables.cells.first(hasPrefix: "The Blacklist,")
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
        addTag("Tag1!", app)
        addTag("Tag 2", app)
        addTag("Tag~3.test", app)
        
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
        
        addMatrixAndBlacklist()
        
        // Search for 'Blacklist'
        libraryNavBar.searchFields.element.wait().tap()
        libraryNavBar.searchFields.element.typeText("Blacklist")
        
        // Check results
        XCTAssertEqual(app.tables.cells.count, 1)
        XCTAssertTrue(app.tables.cells.first(hasPrefix: "The Blacklist,").exists)
    }
    
    func testResetMedia() {
        app.launch()
        
        addMatrixAndBlacklist()
        
        tabBar["Settings"].tap()
        app.tables.cells["Reset Library"].tap()
        // Alert should have popped up
        app.alerts.firstMatch.buttons["Delete"].wait().tap()
        
        tabBar["Library"].tap()
        
        // Give the app a few seconds to reset the data
        // Alternatively: Wait in Settings screen until the ProgressView disappears
        wait(2)
        
        // Should be empty
        XCTAssertEqual(app.tables.cells.count, 0)
    }
    
    func testResetTags() {
        app.launch()
        
        addMatrix()
        
        // Add a few tags
        goToTags(mediaName: "The Matrix", app: app)
        addTag("Action", app)
        addTag("Adventure", app)
        addTag("Horror", app)
        addTag("Comedy", app)
        goBack()
        // No need to press the done button
        goBack()
        
        // Go into settings and reset the tags
        tabBar["Settings"].tap()
        app.tables.cells["Reset Tags"].tap()
        // Alert should have popped up
        app.alerts.firstMatch.buttons["Delete"].wait().tap()
        
        tabBar["Library"].tap()
        
        // Give the app a few seconds to reset the data
        // Alternatively: Wait in Settings screen until the ProgressView disappears
        wait(2)
        
        app.cells.first(hasPrefix: "The Matrix").tap()
        
        // There should be no tags listed in the preview anymore
        XCTAssertTrue(app.tables.cells["Tags, None"].exists)
        
        app.navigationBars["The Matrix"].buttons["Edit"].tap()
        app.cells.first(hasPrefix: "Tags").staticTexts.firstMatch.tap()
        
        wait(1)
        
        XCTAssertEqual(app.tables.cells.count, 0)
    }
    
    func testRenameTag() {
        let oldName = "Old Tag Name"
        let newName = "New Tag"
        
        app.launch()
        addMatrix()
        goToTags(mediaName: "The Matrix", app: app)
        addTag(oldName, app)
        // Rename it
        app.tables.cells[oldName].buttons["Edit"].tap()
        let textField = app.alerts.firstMatch.textFields.firstMatch
        textField.tap()
        // Delete the old name
        textField.typeText(Array(repeating: XCUIKeyboardKey.delete.rawValue, count: oldName.count).joined())
        textField.typeText(newName)
        app.alerts.firstMatch.buttons["Rename"].tap()
        // Check if it worked
        XCTAssertTrue(app.tables.cells[newName].wait().exists)
    }
    
    func goToTags(mediaName: String, app: XCUIApplication) {
        app.cells.first(hasPrefix: mediaName).tap()
        app.navigationBars[mediaName].buttons["Edit"].tap()
        app.cells.first(hasPrefix: "Tags").staticTexts.firstMatch.tap()
    }
    
    func addTag(_ name: String, _ app: XCUIApplication) {
        let navBar = app.navigationBars["Tags"]
        navBar.buttons["Add"].tap()
        app.textFields.element.typeText(name)
        app.alerts.buttons["Add"].tap()
        // Check if it worked
        XCTAssertTrue(app.tables.cells[name].wait().exists)
    }
    
    func goBack() {
        app.navigationBars.element.buttons.firstMatch.tap()
    }
    
    func addMatrix(checkAdded: Bool = true) {
        addMedia("Matrix", name: "The Matrix", type: .movie, checkAdded: checkAdded)
    }
    
    func addBlacklist(checkAdded: Bool = true) {
        addMedia("Blacklist", name: "The Blacklist", type: .show, checkAdded: checkAdded)
    }
    
    func addMatrixAndBlacklist() {
        addMatrix()
        // We need to scroll a bit to fix the add button not being hittable
        app.swipeUp()
        XCTAssertTrue(addMediaButton.waitForHittable(app).isHittable)
        addBlacklist()
    }
    
    func addMedia(_ query: String, name: String, type: MediaType, checkAdded: Bool = true) {
        addMediaButton.tap()
        addMediaSearch.tap()
        addMediaSearch.typeText("\(query)\n")
        app.tables.cells
            .first(hasPrefix: "\(name), \(type == .movie ? "Movie" : "TV Show")")
            .wait()
            .tap()
        if checkAdded {
            XCTAssertTrue(app.tables.cells
                .first(hasPrefix: "\(name),")
                .waitForExistence(timeout: 10))
        }
    }
    
    func wait(_ timeout: TimeInterval = 1) {
        XCTAssertFalse(app.wait(for: .runningBackground, timeout: timeout))
    }
}

enum MediaType {
    case movie, show
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
