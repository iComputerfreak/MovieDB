// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Localized user-generated values entered by the screenshot UI tests.
struct ScreenshotStrings {
    /// Locale selected by Fastlane Snapshot for the current screenshot run.
    let locale: Locale

    private let bundle = Bundle(for: Movie_DBScreenshots.self)

    /// Name assigned to the sample dynamic list.
    var dynamicListName: String {
        String(
            localized: "screenshots.listName.dynamic",
            defaultValue: "5-Star Movies",
            bundle: bundle,
            locale: locale,
            comment: "Name of a dynamic media list created for App Store screenshots"
        )
    }

    /// Name assigned to the sample custom list.
    var customListName: String {
        String(
            localized: "screenshots.listName.custom",
            defaultValue: "Recommend to Ben",
            bundle: bundle,
            locale: locale,
            comment: "Name of a custom media list created for App Store screenshots"
        )
    }
}
