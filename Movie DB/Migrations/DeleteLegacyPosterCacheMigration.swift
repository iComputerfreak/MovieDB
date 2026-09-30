// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation
import OSLog

/// Removes posters previously stored as non-purgeable PNG data in Documents.
struct DeleteLegacyPosterCacheMigration: Migration {
    let migrationKey = "migration_deleteLegacyPosterCache_v1"

    /// Deletes the obsolete poster directory when present.
    func run() throws {
        guard
            let directory = Utils.legacyImagesDirectory,
            FileManager.default.fileExists(atPath: directory.path())
        else {
            return
        }

        try FileManager.default.removeItem(at: directory)
        Logger.migrations.info("Deleted legacy poster cache from Documents.")
    }
}
