//
//  ImportError.swift
//  Movie DB
//
//  Created by Jonas Frey on 20.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation

enum ImportError: LocalizedError {
    case noPermissions
    
    var errorDescription: String? {
        switch self {
        case .noPermissions:
            return "No permissions to open the file."
        }
    }
}
