//
//  MigrationManager.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import os.log

class MigrationManager {
    private(set) var migrations: [Migration.Type] = []
    
    init() {}
    
    func register(_ migration: Migration.Type) {
        migrations.append(migration)
    }
    
    func run() {
        // Do the migrations on a background task
        Task(priority: .medium) {
            Logger.migrations.info("Running migrations...")
            // Instantiate and run the migrations
            for migration in migrations.map({ $0.init() }) where !migration.hasRun {
                do {
                    Logger.migrations.info("Running migration \(migration.migrationKey, privacy: .public)")
                    try await migration.run()
                    // Save successful exit of the migration
                    migration.setCompleted()
                } catch {
                    Logger.migrations.error(
                        // swiftlint:disable:next line_length
                        "Error running migration \(migration.migrationKey, privacy: .public): \(error, privacy: .public)"
                    )
                }
            }
            Logger.migrations.info("Migrations complete.")
        }
    }
}
