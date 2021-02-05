//
//  CoreData Extensions.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}
