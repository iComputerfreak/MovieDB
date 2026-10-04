// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Localized user-generated values entered by the screenshot UI tests.
struct ScreenshotStrings {
    /// Locale selected by Fastlane Snapshot for the current screenshot run.
    let locale: Locale

    private let bundle = Bundle(for: Movie_DBScreenshots.self)

    private var localizedBundle: Bundle {
        let localization = Bundle.preferredLocalizations(
            from: bundle.localizations,
            forPreferences: [locale.identifier]
        ).first ?? "en"

        guard let url = bundle.url(forResource: localization, withExtension: "lproj"),
              let localizedBundle = Bundle(url: url) else {
            return bundle
        }
        return localizedBundle
    }

    /// Name assigned to the sample dynamic list.
    var dynamicListName: String {
        localizedBundle.localizedString(
            forKey: "screenshots.listName.dynamic",
            value: "5-Star Movies",
            table: nil
        )
    }

    /// Name assigned to the sample custom list.
    var customListName: String {
        localizedBundle.localizedString(
            forKey: "screenshots.listName.custom",
            value: "Recommend to Ben",
            table: nil
        )
    }
}
