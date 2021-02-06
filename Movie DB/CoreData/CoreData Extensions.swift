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
}

enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}

extension NSManagedObject {
    /// Sets an optional value inside a NSManagedObject for the given key
    func setOptional<T>(_ value: T?, forKey key: String) {
        willAccessValue(forKey: key)
        setPrimitiveValue(value, forKey: key)
        didAccessValue(forKey: key)
    }
    
    /// Returns the value for the given key, or nil, if the given value does not exist
    func getOptional<T>(forKey key: String) -> T? {
        willAccessValue(forKey: key)
        defer { didAccessValue(forKey: key) }
        // If the stored value is nil, return nil
        guard let value = primitiveValue(forKey: key) else {
            return nil
        }
        // Else, return the stored value, assuming it's the correct type
        return (value as! T)
    }
    
    /// Sets the given value inside a `NSManagedObject` for the given key
    func setTransformerValue<T>(_ value: T, forKey key: String) {
        willAccessValue(forKey: key)
        setPrimitiveValue(value, forKey: key)
        didAccessValue(forKey: key)
    }
    
    /// Returns the value for the given key
    func getTransformerValue<T>(forKey key: String) -> T {
        willAccessValue(forKey: key)
        defer { didAccessValue(forKey: key) }
        return primitiveValue(forKey: key) as! T
    }
}
