// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Tracks whether the latest major-feature announcement has already been shown.
enum Changelog {
    /// Stable identifier for the latest announcement. Change only when publishing another major-feature announcement.
    static let currentIdentifier = "title-import"

    private static let lastSeenIdentifierKey = "lastSeenChangelogIdentifier"

    /// Returns whether the latest announcement has not been shown yet.
    /// - Parameters:
    ///   - identifier: Stable identifier of the announcement being checked.
    ///   - userDefaults: Storage containing the last-seen announcement identifier.
    /// - Returns: `true` when the latest announcement should be presented.
    static func shouldPresent(
        identifier: String = currentIdentifier,
        userDefaults: UserDefaults = .standard
    ) -> Bool {
        userDefaults.string(forKey: lastSeenIdentifierKey) != identifier
    }

    /// Records the latest announcement as shown.
    /// - Parameter userDefaults: Storage in which to persist the current announcement identifier.
    static func markCurrentAsSeen(userDefaults: UserDefaults = .standard) {
        userDefaults.set(currentIdentifier, forKey: lastSeenIdentifierKey)
    }
}
