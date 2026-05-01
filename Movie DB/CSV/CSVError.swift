// Copyright © 2023 Jonas Frey. All rights reserved.

import Foundation

/// Errors thrown during CSV im-/export
enum CSVError: Error {
    case noTMDBID
    case noMediaType
    case mediaAlreadyExists
    case requiredHeaderMissing(CSVKey)
}
