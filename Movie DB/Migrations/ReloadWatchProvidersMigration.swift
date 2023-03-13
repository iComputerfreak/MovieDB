//
//  ReloadWatchProvidersMigration.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import os.log

struct ReloadWatchProvidersMigration: Migration {
    let migrationKey = "migration_reloadWatchProviders4"
    
    func run() async throws {
        // Easiest to just update the whole library
        _ = try await MediaLibrary.shared.update()
    }
}
