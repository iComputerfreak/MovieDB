//
//  MigrationManager.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

class MigrationManager {
    private(set) var migrations: [Migration.Type] = []
    
    init() {}
    
    func register(_ migration: Migration.Type) {
        migrations.append(migration)
    }
    
    func run() {
        // Instantiate and run the migrations
        for migration in migrations.map({ $0.init() }) where !migration.hasRun {
            do {
                try migration.run()
            } catch {
                print("Error running migration \(migration.migrationKey): \(error)")
            }
        }
    }
}
