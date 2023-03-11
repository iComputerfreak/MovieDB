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
    static let general = Logger("general")
    static let viewCycle = Logger("viewCycle")
    static let coreData = Logger("coreData")
    static let migrations = Logger("migrations")
    static let api = Logger("api")
    static let network = Logger("network")
    static let library = Logger("library")
    static let importExport = Logger("importExport")
    static let background = Logger("background")
    static let appStore = Logger("appStore")
    static let settings = Logger("settings")
    static let addMedia = Logger("addMedia")
    static let detail = Logger("detail")
    static let fileSystem = Logger("fileSystem")
    
    /*
     * Log Levels:
     * - debug: useful only during debugging (alias: trace)
     * - info: helpful, but not essential for troubleshooting
     * - notice: essential for troubleshooting
     * - error: error seen during execution (alias: warning)
     * - fault: bug in program
     *
     * Source: https://developer.apple.com/videos/play/wwdc2020/10168/ from 9:32
     */
    
    // Personal rules:
    // - Use warning for less-serious errors
    // - Don't use trace
}
