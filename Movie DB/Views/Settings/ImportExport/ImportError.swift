// Copyright © 2023 Jonas Frey. All rights reserved.

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
