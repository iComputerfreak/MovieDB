//
//  Logging.swift
//  Movie DB
//
//  Created by Jonas Frey on 07.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import os.log

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    
    private init(_ category: String) {
        self.init(subsystem: Self.subsystem, category: category)
    }
    
    // MARK: Categories
    static let viewCycle = Logger("viewCycle")
    static let coreData = Logger("coreData")
    static let migrations = Logger("migrations")
    static let api = Logger("api")
    static let network = Logger("network")
    static let library = Logger("library")
    static let importExport = Logger("importExport")
    static let background = Logger("background")
}
