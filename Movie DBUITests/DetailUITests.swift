//
//  Movie_DBUITests.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import XCTest

class DetailUITests: XCTestCase {
    var app: XCUIApplication! = nil
    
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
        
    func testShowMovieDetail() {
        app.launch()
        app.addMatrix()
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
        app.wait()
        detailBackButton.tap()
    }
    
    func testShowShowDetail() {
        app.launch()
        app.addBlacklist()
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
        app.wait()
        detailBackButton.tap()
        
        app.tables.cells["Cast"].tap()
        // Give the cast page a bit of time to load
        app.wait()
        detailBackButton.tap()
    }
    
    func testEditShowDetail() {
        app.launch()
        app.addBlacklist()
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
        app.goBack()
        
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
        app.goBack()
        
        app.tables.cells
            .first(hasPrefix: "Notes")
            .staticTexts
            .element(boundBy: 1)
            .tap()
        // Modify
        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("This is a sample note.\nDone.")
        app.goBack()
        
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
        app.goBack()
    }
    
    func disabled_testFilter() {
        // Add and configure Blacklist
        testEditShowDetail()
        // TODO: Test filter
        // Implement after reworking the filter UI
    }
                
    func testRenameTag() {
        let oldName = "Old Tag Name"
        let newName = "New Tag"
        
        app.launch()
        app.addMatrix()
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
}
