//
//  Movie_DBScreenshots.swift
//  Movie DBScreenshots
//
//  Created by Jonas Frey on 13.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import XCTest

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
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testScreenshots() throws {
        app.launch()
        
        _ = app.wait(for: .runningBackground, timeout: 1)
        snapshot("Library")
        
        app.navigationBars.firstMatch.buttons["add-media"].tap()
        app.navigationBars.firstMatch.searchFields.firstMatch.tap()
        app.typeText("Hannibal")
        snapshot("AddMedia")
        
        app.navigationBars.firstMatch.buttons.firstMatch.tap() // Cancel button
        app.navigationBars.firstMatch.buttons.firstMatch.tap() // Close button
        
        // Go to lists
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // Add dynamic list
        app.navigationBars.buttons.firstMatch.tap() // New...
        app.buttons["new-dynamic-list"].tap()
        app.typeText("5-star Movies")
        app.alerts.buttons.element(boundBy: 1).tap() // Add
        
        // Add custom list
        app.navigationBars.buttons.firstMatch.tap()
        app.buttons["new-custom-list"].tap()
        app.typeText("Recommend to Ben")
        app.alerts.buttons.element(boundBy: 1).tap()
        snapshot("Lists")
        
        // Go into Watchlist
        app.cells.buttons.element(boundBy: 2)
        snapshot("Watchlist")
        
        app.navigationBars.buttons.firstMatch.tap()
        app.cells.buttons["Movies"].tap()
        app.navigationBars.firstMatch.buttons.element(boundBy: 1).tap() // Configure...
        app.cells.buttons.element(boundBy: 4).tap() // Media type
        app.collectionViews.firstMatch.buttons.element(boundBy: 1).tap() // Movie
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
