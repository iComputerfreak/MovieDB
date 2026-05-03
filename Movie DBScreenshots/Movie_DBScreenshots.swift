// Copyright © 2023 Jonas Frey. All rights reserved.

import JFTestingUtils
import XCTest

// swiftlint:disable:next blanket_disable_command
// swiftlint:disable implicitly_unwrapped_optional
@MainActor
final class Movie_DBScreenshots: XCTestCase {
    private enum RootTab: Int {
        case library
        case lists
        case settings
    }

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

    var usesGermanCopy: Bool {
        Snapshot.currentLocale.hasPrefix("de") ||
            Snapshot.deviceLanguage.hasPrefix("de") ||
            app.launchArguments.joined(separator: " ").contains("de") ||
            Locale.current.identifier.hasPrefix("de")
    }

    var dynamicListName: String {
        usesGermanCopy ? "5-Sterne-Filme" : "5-Star Movies"
    }

    var customListName: String {
        usesGermanCopy ? "Empfehlungen für Ben" : "Recommend to Ben"
    }

    func testScreenshots() throws {
        app.launch()

        waitForLibrarySampleData()

        if UIDevice.current.userInterfaceIdiom != .pad {
            // We replace this on iPad with the Detail screenshot
            snapshot("Library")
        }

        _ = openAddMedia()
        let addMediaSearchField = app.searchFields.firstMatch
        XCTAssertTrue(addMediaSearchField.waitForExistence(timeout: 10))
        addMediaSearchField.tap()
        addMediaSearchField.typeText("Constantine")
        XCTAssertTrue(app.cells.staticTexts["Constantine"].firstMatch.waitForExistence(timeout: 20))

        if isIPad {
            // We just took screenshot i - 1 and then increased the counter to i
            // Take this as screenshot i + 1 instead of i
            snapshotCounter += 1
        }
        snapshot("AddMedia")

        app.terminate()
        app.launch()
        waitForLibrarySampleData()
        // Go into detail
        app.cells.element(boundBy: 0).tap()

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
        openTab(.lists)

        // Add dynamic list
        app.navigationBars.buttons["new-list"].forceTap() // New...
        app.buttons["new-dynamic-list"].tap()
        app.typeText(dynamicListName)
        app.alerts.buttons.element(boundBy: 1).tap() // Add

        // Add custom list
        app.navigationBars.buttons["new-list"].forceTap()
        app.buttons["new-custom-list"].tap()
        app.typeText(customListName)
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

        app.cells.buttons[dynamicListName].tap()
        let buttonOffset = UIDevice.current.userInterfaceIdiom == .phone ? 1 : 0
        app.navigationBars[dynamicListName].buttons.element(boundBy: buttonOffset).tap() // Configure...

        app.otherElements["color8"].tap()

        app.swipeUp(velocity: .fast)
        app.images["play.tv"].tap()

        // Go into Filter Settings
        let filterSettingsButton = app.buttons["filter-settings"].firstMatch
        for _ in 0 ..< 3 where !filterSettingsButton.exists {
            app.swipeDown(velocity: .fast)
        }
        XCTAssertTrue(filterSettingsButton.waitForExistence(timeout: 10))
        filterSettingsButton.tap()

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
        openTab(.settings)
        snapshot("Settings")
    }

    private func snapshot(_ name: String) {
        Snapshot.snapshot("\(String(format: "%02d", snapshotCounter))_\(name)")
        snapshotCounter += 1
    }

    private func waitForLibrarySampleData() {
        XCTAssertTrue(app.buttons["add-media"].waitForExistence(timeout: 20))
        XCTAssertTrue(app.cells.element(boundBy: 0).waitForExistence(timeout: 30))
    }

    private func openAddMedia() -> Bool {
        let addMediaButton = app.buttons["add-media"]
        XCTAssertTrue(addMediaButton.waitForExistence(timeout: 10))
        addMediaButton.tap()
        return app.segmentedControls.firstMatch.waitForExistence(timeout: 5)
    }

    private func openTab(_ tab: RootTab) {
        let button = app.tabBars.buttons[tabLabel(for: tab)]
        if button.waitForExistence(timeout: 3) {
            button.forceTap()
            return
        }

        let fallbackButton = app.buttons[tabSymbolName(for: tab)].firstMatch
        XCTAssertTrue(fallbackButton.waitForExistence(timeout: 10))
        fallbackButton.forceTap()
    }

    private func tabLabel(for tab: RootTab) -> String {
        switch tab {
        case .library:
            usesGermanCopy ? "Mediathek" : "Library"
        case .lists:
            usesGermanCopy ? "Listen" : "Lists"
        case .settings:
            usesGermanCopy ? "Einstellungen" : "Settings"
        }
    }

    private func tabSymbolName(for tab: RootTab) -> String {
        switch tab {
        case .library:
            "film"
        case .lists:
            "list.bullet"
        case .settings:
            "gear"
        }
    }
}
