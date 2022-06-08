//
//  FilterUITests.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 08.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import XCTest

class FilterUITests: XCTestCase {
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
    
    func addSampleMedias() {
        app.addMatrix()
        app.swipeUp()
        app.addBlacklist()
        app.swipeUp()
        app.addMedia("Fight Club", name: "Fight Club", type: .movie)
        app.swipeUp()
        app.addMedia("Stranger Things", name: "Stranger Things", type: .show)
    }
    
    func configureFilter(_ key: String, configureValue: () -> Void) {
        // We start at the library view
        app.buttons["More"].tap()
        app.buttons["Filter"].tap()
        // Change the desired filter setting
        app.cells[key].tap()
        configureValue()
        app.buttons["Apply"].tap()
    }
    
    func test() {
        app.launch()
        
        addSampleMedias()
        
        configureFilter("Media Type") {
            app.cells["Movie"].tap()
            app.goBack()
        }
        
        app.wait(1)
        
        XCTAssertEqual(app.cells.count, 2)
        XCTAssert(app.cells.first(hasPrefix: "Fight Club").exists)
        XCTAssert(app.cells.first(hasPrefix: "The Matrix").exists)
        XCTAssert(app.staticTexts["2 objects"].exists)
    }
    
    func testFilterWatched() {
        app.launch()
        
        app.addMatrixAndBlacklist()
        
        // Add a few tags
        goToTags(mediaName: "The Matrix", app: app)
        addTag("Action", app)
        addTag("Adventure", app)
        addTag("Horror", app)
        addTag("Comedy", app)
        
        // Select some
        app.cells["Action"].tap()
        app.cells["Horror"].tap()
        
        app.goBack()
        // No need to press the done button
        app.goBack()
        
        // MARK: Reset the library
        
        app.tabBar["Settings"].tap()
        app.tables.cells["Reset Library"].tap()
        // Alert should have popped up
        app.alerts.firstMatch.buttons["Delete"].wait().tap()
        
        // Give the app a few seconds to reset the data
        // Alternatively: Wait in Settings screen until the ProgressView disappears
        app.wait(2)
        
        app.tabBar["Library"].tap()
        
        // TODO: Remove when fixed
        // Workaround for refreshing the library
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        app.wait(1)
        app.launch()
        
        // Should be empty
        XCTAssertEqual(app.tables.cells.count, 0)
        
        // Check if tags were deleted
        app.addMatrix()
        
        app.cells.first(hasPrefix: "The Matrix").tap()
        
        // There should be no tags listed in the preview anymore
        XCTAssertTrue(app.tables.cells["Tags, None"].exists)
        
        app.navigationBars["The Matrix"].buttons["Edit"].tap()
        app.cells.first(hasPrefix: "Tags").staticTexts.firstMatch.tap()
        
        app.wait(1)
        
        XCTAssertEqual(app.tables.cells.count, 0)
    }
    
    func goToTags(mediaName: String, app: XCUIApplication) {
        app.cells.first(hasPrefix: mediaName).tap()
        app.navigationBars[mediaName].buttons["Edit"].wait().tap()
        app.cells.first(hasPrefix: "Tags").staticTexts.firstMatch.wait().tap()
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
