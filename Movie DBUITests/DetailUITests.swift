//
//  Movie_DBUITests.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import XCTest

class DetailUITests: XCTestCase {
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
        
    func testShowMovieDetail() {
        app.launch()
        app.addMatrix()
        app.cells.staticTexts["The Matrix"]
            .wait()
            .tap()
        // Title cell
        app.cells.staticTexts["The Matrix"].firstMatch.tap()
        let detailBackButton = app.navigationBars.element.buttons.firstMatch
        detailBackButton.tap()
        app.cells.staticTexts["Description"].tap()
        detailBackButton.tap()
        app.swipeUp()
        app.cells.staticTexts["Cast"].tap()
        app.cells.staticTexts["Keanu Reeves"]
            .wait()
        detailBackButton.tap()
    }
    
    func testShowShowDetail() {
        app.launch()
        app.addBlacklist()
        app.cells.staticTexts["The Blacklist"]
            .wait()
            .tap()
        // Title cell
        app.cells.staticTexts["The Blacklist"]
            .wait()
            .tap()
        let detailBackButton = app.navigationBars.element.buttons.firstMatch
        detailBackButton.tap()
        app.cells.staticTexts["Description"]
            .wait()
            .tap()
        detailBackButton.tap()
        app.swipeUp()
        app.cells.staticTexts["Seasons"]
            .wait()
            .tap()
        app.wait()
        detailBackButton.tap()
        
        app.cells.staticTexts["Cast"].tap()
        // Give the cast page a bit of time to load
        app.wait()
        detailBackButton.tap()
    }
    
    func testEditShowDetail() {
        app.launch()
        app.addBlacklist()
        app.cells.staticTexts["The Blacklist"]
            .wait()
            .tap()
        // Go into edit mode
        let navBar = app.navigationBars.element
        navBar.buttons["More"].tap()
        app.buttons["Edit"].tap()
        
        app.cells.containing(.staticText, identifier: "Personal Rating")
            .buttons["Increment"]
            .tap(withNumberOfTaps: 7, numberOfTouches: 1)
        
        app.cells.staticTexts["Watched?"]
            .wait()
            .tap()
        // Toggle "Unknown"
        app.switches["Unknown"].tap()
        // Increase season to 3
        app.steppers.firstMatch.buttons["Increment"]
            .tap(withNumberOfTaps: 3, numberOfTouches: 1)
        app.steppers.element(boundBy: 1).buttons["Increment"]
            // Increase episode to 15
            .tap(withNumberOfTaps: 10, numberOfTouches: 1)
        app.steppers.element(boundBy: 1).buttons["Increment"]
            .tap(withNumberOfTaps: 5, numberOfTouches: 1)
        app.goBack()
        
        app.cells.containing(.staticText, identifier: "Watch again?")
            .buttons["No"]
            .tap()
        
        app.cells.staticTexts["Tags"]
            .tap()
        
        // Create tags
        addTag("Tag1!", app)
        addTag("Tag 2", app)
        addTag("Tag~3.test", app)
        
        app.cells.staticTexts["Tag1!"].tap()
        app.cells.staticTexts["Tag~3.test"].tap()
        
        // Modify
        app.goBack()
        
        app.cells.staticTexts["Notes"]
            .tap()
        // Modify
        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("This is a sample note.\nDone.")
        app.goBack()
        
        // Stop Editing
        navBar.buttons["More"].tap()
        app.buttons["Done"].tap()
        
        // Assertions
        let starImages = app.cells.containing(.staticText, identifier: "Personal Rating").images
        let labels = ["Favourite", "Favourite", "Favourite", "Half Star", "Favourite"]
        for i in 0..<5 {
            XCTAssertEqual(
                starImages.element(boundBy: i).label,
                labels[i]
            )
        }
        XCTAssertEqual(
            app.cells.containing(.staticText, identifier: "Watched?").staticTexts.element(boundBy: 1).label,
            "Season 3, Episode 15"
        )
        XCTAssertEqual(
            app.cells.containing(.staticText, identifier: "Watch again?").staticTexts.element(boundBy: 1).label,
            "No"
        )
        XCTAssertEqual(
            app.cells.containing(.staticText, identifier: "Tags").staticTexts.element(boundBy: 1).label,
            "Tag1!, Tag~3.test"
        )
        XCTAssertEqual(
            app.cells.containing(.staticText, identifier: "Notes").staticTexts.element(boundBy: 1).label,
            "This is a sample note.\nDone."
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
        app.cells.containing(.staticText, identifier: oldName).buttons["Edit"].tap()
        let textField = app.alerts.firstMatch.textFields.firstMatch
        textField.tap()
        // Delete the old name
        textField.typeText(Array(repeating: XCUIKeyboardKey.delete.rawValue, count: oldName.count).joined())
        textField.typeText(newName)
        app.alerts.firstMatch.buttons["Rename"].tap()
        // Check if it worked
        XCTAssertTrue(app.cells.staticTexts[newName].wait().exists)
    }
    
    func testDeleteTag() {
        app.launch()
        app.addMatrix()
        goToTags(mediaName: "The Matrix", app: app)
        addTag("Tag 1", app)
        addTag("Tag 2", app)
        // Delete Tag 1
        app.cells.containing(.staticText, identifier: "Tag 1").firstMatch.swipeLeft()
        app.cells.buttons["Delete"].tap()
        app.wait(1)
        // Check if it worked
        XCTAssertFalse(app.cells.staticTexts["Tag 1"].wait().exists)
    }
    
    func goToTags(mediaName: String, app: XCUIApplication) {
        app.cells.staticTexts[mediaName].tap()
        app.navigationBars.firstMatch.buttons["Edit"].tap()
        app.cells.staticTexts["Tags"].wait().tap()
    }
    
    func addTag(_ name: String, _ app: XCUIApplication) {
        let navBar = app.navigationBars["Tags"]
        navBar.buttons["Add"].tap()
        app.textFields.element.typeText(name)
        app.alerts.buttons["Add"].tap()
        // Check if it worked
        XCTAssertTrue(app.cells.staticTexts[name].wait().exists)
    }
}
