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
    
    /// Sets an optional `Int` inside a NSManagedObject as an `Int64` for the given key
    func setOptionalInt(_ value: Int?, forKey key: String) {
        willAccessValue(forKey: key)
        setPrimitiveValue(value == nil ? nil : Int64(value!), forKey: key)
        didAccessValue(forKey: key)
    }
    
    /// Returns the value for the given key, or nil, if the given value does not exist
    func getOptionalInt(forKey key: String) -> Int? {
        willAccessValue(forKey: key)
        defer { didAccessValue(forKey: key) }
        // If the stored value is nil, return nil
        guard let value = primitiveValue(forKey: key) else {
            return nil
        }
        // Else, return the stored value, assuming it's the correct type
        return Int(value as! Int64)
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
    
    /// Sets the given `Int` as an `Int64` for the given key
    func setInt(_ value: Int, forKey key: String) {
        willAccessValue(forKey: key)
        setPrimitiveValue(Int64(value), forKey: key)
        didAccessValue(forKey: key)
    }
    
    /// Returns the `Int` value for the given key
    func getInt(forKey key: String) -> Int {
        willAccessValue(forKey: key)
        defer { didAccessValue(forKey: key) }
        return Int(primitiveValue(forKey: key) as! Int64)
    }
}

extension NSSet {
    
    /// Converts this `NSSet` into a `Set`
    func set<T>(of type: T.Type) -> Set<T> {
        return self as! Set<T>
    }
    
    func array<T: Hashable>(of type: T.Type) -> [T] {
        return [T](self.set(of: type))
    }
    
    var isEmpty: Bool {
        self.count == 0
    }
    
}
