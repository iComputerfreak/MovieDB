//
//  ReloadWatchProvidersMigration.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import os.log

/// A migration that reload the whole library when executed
struct ReloadLibraryMigration: Migration {
    // Increase the version number of the key to force devices that have already run this migration to run it again
    // e.g., when we add other changes that require another reload
    let migrationKey = "migration_reloadLibrary_v1"
    
    func run() async throws {
        _ = try await MediaLibrary.shared.update()
    }
}
