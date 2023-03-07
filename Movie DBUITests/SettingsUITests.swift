//
//  Movie_DBUITests.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import XCTest

class SettingsUITests: XCTestCase {
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
    
    func testResetMedia() {
        app.launch()
        
        app.addMatrixAndBlacklist()
        
        // Add a few tags
        goToTags(mediaName: "The Matrix", app: app)
        addTag("Action", app)
        addTag("Adventure", app)
        addTag("Horror", app)
        addTag("Comedy", app)
        
        // Select some
        app.cells.staticTexts["Action"].tap()
        app.cells.staticTexts["Horror"].tap()
        
        app.goBack()
        // No need to press the done button
        app.goBack()
        
        // MARK: Reset the library
        
        app.tabBar["Settings"].tap()
        app.buttons["Reset Library"].tap()
        // Alert should have popped up
        app.alerts.firstMatch.buttons["Delete"].wait().tap()
        
        // Give the app a few seconds to reset the data
        // Alternatively: Wait in Settings screen until the ProgressView disappears
        app.wait(2)
        
        app.tabBar["Library"].tap()
        
        // TODO: Remove when fixed
        // Workaround for refreshing the library
//        XCUIDevice.shared.press(XCUIDevice.Button.home)
//        XCTAssertFalse(app.wait(for: .unknown, timeout: 1))
//        app.launch()
        
        app.wait(3)
        
        // Should be empty
        XCTAssertFalse(app.cells.staticTexts["The Blacklist"].exists)
        XCTAssertFalse(app.cells.staticTexts["The Matrix"].exists)
        
        // Check if tags were deleted
        app.addMatrix()
        
        app.cells.staticTexts["The Matrix"].tap()
        
        // There should be no tags listed in the preview anymore
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "Tags").staticTexts["None"].exists)
        
        app.navigationBars["The Matrix"].buttons["Edit"].tap()
        app.cells.staticTexts["Tags"].tap()
        
        app.wait(1)
        
        XCTAssertFalse(app.cells.staticTexts["Action"].exists)
        XCTAssertFalse(app.cells.staticTexts["Adventure"].exists)
        XCTAssertFalse(app.cells.staticTexts["Horror"].exists)
        XCTAssertFalse(app.cells.staticTexts["Comedy"].exists)
    }
    
    func goToTags(mediaName: String, app: XCUIApplication) {
        app.cells.staticTexts.first(hasPrefix: mediaName).tap()
        app.navigationBars[mediaName].buttons["Edit"].tap()
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
