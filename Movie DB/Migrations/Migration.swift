//
//  Migration.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation

protocol Migration {
    var migrationKey: String { get }
    /// Returns whether the migration has been run on this device before
    var hasRun: Bool { get }
    /// Executes the migration
    func run() throws
    
    init()
}

extension Migration {
    var hasRun: Bool {
        UserDefaults.standard.bool(forKey: migrationKey)
    }
}
