// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

extension Strings {
    /// Provides localized copy for major-feature announcements.
    enum Changelog {
        static let title = String(
            localized: "changelog.title",
            defaultValue: "What's New",
            comment: "Navigation title for the major-feature announcement sheet"
        )
        static let titleImportTitle = String(
            localized: "changelog.titleImport.title",
            defaultValue: "Import CSV by Title",
            comment: "Title of the changelog item announcing title-based CSV import"
        )
        static let titleImportDescription = String(
            localized: "changelog.titleImport.description",
            defaultValue: "Bring an existing movie or show list into Movie DB using titles and optional details such as year, director, or runtime. Review the matches before importing them. You can find the new import in Settings under Import & Export.",
            comment: "Description of the changelog item announcing title-based CSV import"
        )
        static let dismissButton = String(
            localized: "changelog.dismissButton",
            defaultValue: "Got It",
            comment: "Button that dismisses the major-feature announcement sheet"
        )
    }
}
