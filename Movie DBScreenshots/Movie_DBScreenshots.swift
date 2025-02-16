//
//  Movie_DBScreenshots.swift
//  Movie DBScreenshots
//
//  Created by Jonas Frey on 13.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import JFTestingUtils
import XCTest

// swiftlint:disable:next blanket_disable_command
// swiftlint:disable implicitly_unwrapped_optional
@MainActor
final class Movie_DBScreenshots: XCTestCase {
    var app: XCUIApplication!
    var snapshotCounter: Int!
    
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--screenshots"]
        setupSnapshot(app)
        // Reset snapshot counter
        snapshotCounter = 1
        // If device is iPad, put it into landscape mode
        if isIPad {
            XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
        }
    }
    
    // swiftlint:disable:next unneeded_override
    override func tearDown() async throws {
        try await super.tearDown()
    }
    
    var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    func testScreenshots() throws {
        app.launch()
        
        // Give the app a second to load the sample data and thumbnails
        _ = app.wait(for: .runningBackground, timeout: 3)
        if UIDevice.current.userInterfaceIdiom != .pad {
            // We replace this on iPad with the Detail screenshot
            snapshot("Library")
        }
        
        app.navigationBars.firstMatch.buttons["add-media"].tap()
        app.textFields.firstMatch.tap()
        app.typeText("Constantine")
        
        if isIPad {
            // We just took screenshot i - 1 and then increased the counter to i
            // Take this as screenshot i + 1 instead of i
            snapshotCounter += 1
        }
        snapshot("AddMedia")
        
        app.navigationBars.firstMatch.buttons.firstMatch.tap() // Cancel button
        // Go into detail
        app.cells.buttons.element(boundBy: 0).forceTap()
        
        if isIPad {
            // Now the counter is i + 2, but we want it to be i (which we left out earlier)
            snapshotCounter -= 2
        }
        snapshot("Detail")
        if isIPad {
            // We are now at i + 1 again, but we should be at i + 2 for the correct ordering to continue
            snapshotCounter += 1
            // In total, we increased by 2 and subtracted by 2, so we are at +/- 0 offset again.
        }
        
        app.swipeUp(velocity: .fast)
        // Wait for scrolling to finish
        XCTAssertFalse(app.wait(for: .runningBackground, timeout: 2))
        snapshot("Detail2")
        
        // Go to lists
        app.buttons["gear"].tap()

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
        
        if !(UIDevice.current.userInterfaceIdiom == .pad) {
            // We don't need this screenshot on iPad
            snapshot("Lists")
        }
        
        // Go into Watchlist
        app.cells.buttons.element(boundBy: 1).tap()
        snapshot("WList")
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            app.navigationBars.buttons.firstMatch.tap() // Back
        }
        app.cells.buttons["5-star Movies"].tap()
        let buttonOffset = UIDevice.current.userInterfaceIdiom == .phone ? 1 : 0
        app.navigationBars["5-star Movies"].buttons.element(boundBy: buttonOffset).tap() // Configure...
        
        app.otherElements["color8"].tap()
        
        app.swipeUp(velocity: .fast)
        app.images["play.tv"].tap()
        
        // Go into Filter Settings
        app.swipeDown(velocity: .fast)
        app.cells.element(boundBy: 1).staticTexts.firstMatch.tap()
        
        app.cells.buttons.element(boundBy: 3).tap() // Media type
        app.collectionViews.firstMatch.buttons.element(boundBy: 1).tap() // Movie
        app.cells.buttons.element(boundBy: 5).tap() // Personal Rating
        // Increase to 5 stars
        app.steppers.firstMatch.buttons["Increment"].tap(withNumberOfTaps: 5, numberOfTouches: 5)
        app.steppers.firstMatch.buttons["Increment"].tap(withNumberOfTaps: 5, numberOfTouches: 5)
        app.navigationBars.buttons.firstMatch.tap() // Back
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
