//
//  CSVEncoder.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

/// Encodes data into strings, used for creating CSV files
struct CSVEncoder {
    
    /// The current data set
    var data: [String: String]
    
    /// The separator used for encoding arrays
    var arraySeparator: String
    
    /// Creates a new encoder with the given array separator
    /// - Parameter arraySeparator: The separator used for encoding arrays
    init(arraySeparator: String) {
        self.data = [:]
        self.arraySeparator = arraySeparator
    }
    
    /// Encodes the given value for the given key
    /// - Parameters:
    ///   - value: The value to encode
    ///   - key: They key to encode the value for
    mutating func encode<T>(_ value: T, forKey key: CSVCodingKey) where T: LosslessStringConvertible {
        data[key] = value.description
    }
    
    /// Encodes the given value for the given key
    /// - Parameters:
    ///   - value: The value to encode
    ///   - key: They key to encode the value for
    mutating func encode<T>(_ value: T, forKey key: CSVCodingKey) where T: RawRepresentable, T.RawValue: LosslessStringConvertible {
        data[key] = value.rawValue.description
    }
    
    
    /// Encodes the given value for the given key
    /// - Parameters:
    ///   - value: The value to encode
    ///   - key: They key to encode the value for
    mutating func encode<T>(_ value: T?, forKey key: CSVCodingKey) where T: LosslessStringConvertible {
        data[key] = value?.description
    }
    
    /// Encodes the given value for the given key
    /// - Parameters:
    ///   - value: The value to encode
    ///   - key: They key to encode the value for
    mutating func encode<T>(_ value: T?, forKey key: CSVCodingKey) where T: RawRepresentable, T.RawValue: LosslessStringConvertible {
        data[key] = value?.rawValue.description
    }
    
    
    /// Encodes the given array for the given key
    /// - Parameters:
    ///   - value: The array to encdoe
    ///   - key: The key to encode the array for
    mutating func encode<T>(_ value: [T], forKey key: CSVCodingKey) where T: LosslessStringConvertible {
        data[key] = value.map(\.description).joined(separator: arraySeparator)
    }
    
    /// Encodes the given array for the given key
    /// - Parameters:
    ///   - value: The array to encdoe
    ///   - key: The key to encode the array for
    mutating func encode<T>(_ value: [T], forKey key: CSVCodingKey) where T: RawRepresentable, T.RawValue: LosslessStringConvertible {
        data[key] = value.map(\.rawValue.description).joined(separator: arraySeparator)
    }
    
}
