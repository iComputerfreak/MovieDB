//
//  Movie_DBUITests.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import XCTest

class LibraryUITests: XCTestCase {
    var app: XCUIApplication!

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
        app.addMedia("Matrix", name: "The Matrix", type: .movie)
    }
    
    func testAddShow() {
        app.launch()
        app.addMedia("Blacklist", name: "The Blacklist", type: .show)
    }
    
    func testAddTwice() {
        app.launch()
        app.addMatrix()
        // We need to scroll a bit to fix the add button not being hittable
        app.swipeUp()
        XCTAssertTrue(app.addMediaButton.waitForHittable(app).isHittable)
        // Add it again
        app.addMatrix(checkAdded: false)
        app.wait(1)
        // Now we should have been displayed the error
        XCTAssertEqual(app.alerts.element.label, "Already Added")
    }
    
    func testAddAndRemove() {
        app.launch()
        app.addMatrix()
        // Delete the new movie
        app.cells.staticTexts["The Matrix"]
            .swipeLeft()
        app.buttons["Delete"]
            .wait()
            .tap()
        app.wait(1)
        // Should not exist anymore
        XCTAssertFalse(app.cells.staticTexts["The Matrix"].exists)
    }
    
    func disabled_testFilter() {
        // Add and configure Blacklist
//        testEditShowDetail()
        // TODO: Test filter
        // Implement after reworking the filter UI
    }
    
    func testSearch() {
        app.launch()
        
        app.addMatrixAndBlacklist()
        
        // Search for 'Blacklist'
        app.libraryNavBar.searchFields.element.wait().tap()
        app.libraryNavBar.searchFields.element.typeText("Blacklist")
        
        // Check results
        XCTAssertTrue(app.cells.staticTexts["The Blacklist"].exists)
        XCTAssertFalse(app.cells.staticTexts["The Matrix"].exists)
    }
}
