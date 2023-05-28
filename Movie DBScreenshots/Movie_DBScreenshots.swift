//
//  Movie_DBScreenshots.swift
//  Movie DBScreenshots
//
//  Created by Jonas Frey on 13.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import JFUtils
import XCTest

// swiftlint:disable:next blanket_disable_command
// swiftlint:disable implicitly_unwrapped_optional
final class Movie_DBScreenshots: XCTestCase {
    var app: XCUIApplication!
    var snapshotCounter: Int!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--screenshots"]
        setupSnapshot(app)
        // Reset snapshot counter
        snapshotCounter = 1
        // If device is iPad, put it into landscape mode
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
        }
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testScreenshots() throws {
        app.launch()
        
        // Give the app a second to load the sample data and thumbnails
        _ = app.wait(for: .runningBackground, timeout: 3)
        snapshot("Library")
        
        app.navigationBars.firstMatch.buttons["add-media"].tap()
        app.navigationBars.firstMatch.searchFields.firstMatch.tap()
        app.typeText("Constantine")
        snapshot("AddMedia")
        
        app.navigationBars.firstMatch.buttons.firstMatch.tap() // Cancel button
        app.navigationBars.firstMatch.buttons.firstMatch.tap() // Close button
        
        // Go into detail
        app.cells.buttons.element(boundBy: 0).forceTap()
        snapshot("Detail")
        app.swipeUp()
        // Wait for scrolling to finish
        XCTAssertFalse(app.wait(for: .runningBackground, timeout: 2))
        snapshot("Detail2")
        
        // Go to lists
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // Add dynamic list
        app.navigationBars.buttons["new-list"].forceTap() // New...
        app.buttons["new-dynamic-list"].tap()
        app.typeText("5-star Movies")
        app.alerts.buttons.element(boundBy: 1).tap() // Add
        
        // Add custom list
        app.navigationBars.buttons["new-list"].forceTap()
        app.buttons["new-custom-list"].tap()
        app.typeText("Recommend to Ben")
        app.alerts.buttons.element(boundBy: 1).tap()
        snapshot("Lists")
        
        // Go into Watchlist
        app.cells.buttons.element(boundBy: 2).tap()
        snapshot("WList")
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            app.navigationBars.buttons.firstMatch.tap() // Back
        }
        app.cells.buttons["5-star Movies"].tap()
        let buttonOffset = UIDevice.current.userInterfaceIdiom == .phone ? 1 : 0
        app.navigationBars["5-star Movies"].buttons.element(boundBy: buttonOffset).tap() // Configure...
        app.cells.buttons.element(boundBy: 4).tap() // Media type
        app.collectionViews.firstMatch.buttons.element(boundBy: 1).tap() // Movie
        app.cells.buttons.element(boundBy: 6).tap() // Personal Rating
        // Increase to 5 stars
        app.steppers.firstMatch.buttons["Increment"].tap(withNumberOfTaps: 5, numberOfTouches: 5)
        app.steppers.firstMatch.buttons["Increment"].tap(withNumberOfTaps: 5, numberOfTouches: 5)
        app.navigationBars.buttons.firstMatch.tap() // Back
        
        snapshot("ListConfiguration")
        app.navigationBars.firstMatch.buttons.firstMatch.tap() // Done
        
        // Go to settings
        app.tabBars.buttons.element(boundBy: 3).tap()
        snapshot("Settings")
    }

    private func snapshot(_ name: String) {
        Snapshot.snapshot("\(String(format: "%02d", snapshotCounter))_\(name)")
        snapshotCounter += 1
    }
}
