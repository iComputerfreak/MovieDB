//
//  CSVError.swift
//  Movie DB
//
//  Created by Jonas Frey on 16.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation

/// Errors thrown during CSV im-/export
enum CSVError: Error {
    case noTMDBID
    case noMediaType
    case mediaAlreadyExists
    case requiredHeaderMissing(CSVManager.CSVKey)
}
