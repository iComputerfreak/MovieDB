//
//  CSVDecoder.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

/// Decodes data from Strings, like CSV files
struct CSVDecoder {
    
    enum CSVDecodingError: Error {
        case typeMismatch(CSVCodingKey)
        case keyNotFound(CSVCodingKey)
        case dataCorrupted
    }
    
    /// The data set
    let data: [String: String]
    
    /// The separator used for decoding arrays
    var arraySeparator: String
    
    /// Creates a new decoder with the given data set and array separator
    /// - Parameters:
    ///   - data: The data set to decode from
    ///   - arraySeparator: The separator used for decoding arrays
    init(data: [String: String], arraySeparator: String) {
        self.data = data
        self.arraySeparator = arraySeparator
    }
    
    
    /// Decodes a value of the given type for the given key
    /// - Parameters:
    ///   - type: The type of the value to decode
    ///   - key: The key to decode the value from
    /// - Throws: `CSVDecodingError`
    /// - Returns: The decoded value
    func decode<T>(_ type: T.Type, forKey key: CSVCodingKey) throws -> T where T: LosslessStringConvertible {
        return try decode(T.self, forKey: key, with: T.init)
    }
    
    /// Decodes a value of the given type for the given key
    /// - Parameters:
    ///   - type: The type of the value to decode
    ///   - key: The key to decode the value from
    /// - Throws: `CSVDecodingError`
    /// - Returns: The decoded value
    func decode<T>(_ type: T.Type, forKey key: CSVCodingKey) throws -> T where T: RawRepresentable, T.RawValue: LosslessStringConvertible {
        return try decode(T.self, forKey: key, with: { stringValue in
            guard let rawValue = T.RawValue(stringValue) else {
                return nil
            }
            return T.init(rawValue: rawValue)
        })
    }
    
    
    /// Decodes a value of the given type for the given key
    /// - Parameters:
    ///   - type: The type of the value to decode
    ///   - key: The key to decode the value from
    /// - Throws: `CSVDecodingError`
    /// - Returns: The decoded value
    func decode<T>(_ type: T?.Type, forKey key: CSVCodingKey) throws -> T? where T: LosslessStringConvertible {
        return try decodeOptional(T?.self, forKey: key, with: T.init)
    }
    
    /// Decodes a value of the given type for the given key
    /// - Parameters:
    ///   - type: The type of the value to decode
    ///   - key: The key to decode the value from
    /// - Throws: `CSVDecodingError`
    /// - Returns: The decoded value
    func decode<T>(_ type: T?.Type, forKey key: CSVCodingKey) throws -> T? where T: RawRepresentable, T.RawValue: LosslessStringConvertible {
        return try decodeOptional(T?.self, forKey: key, with: { stringValue in
            guard let rawValue = T.RawValue(stringValue) else {
                return nil
            }
            return T.init(rawValue: rawValue)
        })
    }
    
    
    /// Decodes an array of the given type for the given key
    /// - Parameters:
    ///   - type: The type of the array to decode
    ///   - key: The key to decode the array from
    /// - Throws: `CSVDecodingError`
    /// - Returns: The decoded array
    func decode<T>(_ type: [T].Type, forKey key: CSVCodingKey) throws -> [T] where T: LosslessStringConvertible {
        return try decodeArray([T].self, forKey: key, with: T.init)
    }
    
    /// Decodes an array of the given type for the given key
    /// - Parameters:
    ///   - type: The type of the array to decode
    ///   - key: The key to decode the array from
    /// - Throws: `CSVDecodingError`
    /// - Returns: The decoded array
    func decode<T>(_ type: [T].Type, forKey key: CSVCodingKey) throws -> [T] where T: RawRepresentable, T.RawValue: LosslessStringConvertible {
        return try decodeArray([T].self, forKey: key, with: { stringValue in
            guard let rawValue = T.RawValue(stringValue) else {
                return nil
            }
            return T.init(rawValue: rawValue)
        })
    }
    
    
    private func decode<T>(_ type: T.Type, forKey key: CSVCodingKey, with initializer: (String) -> T?) throws -> T {
        guard let stringValue = data[key] else {
            throw CSVDecodingError.keyNotFound(key)
        }
        guard let value = initializer(stringValue) else {
            throw CSVDecodingError.typeMismatch(key)
        }
        return value
    }
    
    private func decodeOptional<T>(_ type: T?.Type, forKey key: CSVCodingKey, with initializer: (String) -> T?) throws -> T? {
        // Empty string is the same as nil value in CSV
        guard let stringValue = data[key], !stringValue.isEmpty else {
            // If the value does not exist or is nil/empty, we return nil
            return nil
        }
        guard let value = initializer(stringValue) else {
            // If data exists, but is of wrong type, we throw an error
            throw CSVDecodingError.typeMismatch(key)
        }
        return value
    }
    
    private func decodeArray<T>(_ type: [T].Type, forKey key: CSVCodingKey, with initializer: (String) -> T?) throws -> [T] {
        guard let stringValue = data[key] else {
            throw CSVDecodingError.keyNotFound(key)
        }
        // An empty string value is an empty array
        guard !stringValue.isEmpty else {
            return []
        }
        let array = stringValue.components(separatedBy: arraySeparator)
        var returnArray: [T] = []
        for value in array {
            // We have to check, that every value of the array matches
            guard let value = initializer(value) else {
                throw CSVDecodingError.typeMismatch(key)
            }
            returnArray.append(value)
        }
        return returnArray
    }
    
}
