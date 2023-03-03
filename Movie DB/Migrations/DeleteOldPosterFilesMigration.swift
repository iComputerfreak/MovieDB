//
//  DeleteOldPosterFilesMigration.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import RegexBuilder

struct DeleteOldPosterFilesMigration: Migration {
    let migrationKey = "migration_deleteOldPosterFiles"
    
    func run() throws {
        // Example UUID: E621E1F8-C36C-495A-93FC-0C247A3E6E5F
        // 8-4-4-4-12
        let uuidFilenameRegex = Regex {
            Repeat(count: 8) {
                .hexDigit
            }
            "-"
            Repeat(count: 3) {
                Repeat(count: 4) {
                    .hexDigit
                }
                "-"
            }
            Repeat(count: 12) {
                .hexDigit
            }
            ChoiceOf {
                ".png"
                ".jpg"
                ".jpeg"
            }
        }
        
        // Go over all images on disk and delete all images that do not match the regex
        if let url = Utils.imagesDirectory() {
            let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for file in files {
                let filename = file.lastPathComponent
                if try uuidFilenameRegex.wholeMatch(in: filename) == nil {
                    // Make sure we only delete images
                    if filename.hasSuffix(".png") || filename.hasSuffix(".jpg") || filename.hasSuffix(".jpeg") {
                        try FileManager.default.removeItem(at: file)
                    }
                }
            }
        }
    }
}
