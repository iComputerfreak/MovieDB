//
//  CoreData Extensions.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
    static let mediaType = CodingUserInfoKey(rawValue: "mediaType")!
}

enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}
