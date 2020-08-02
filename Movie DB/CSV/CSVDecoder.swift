//
//  CSVDecoder.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

struct CSVDecoder {
    
    enum CSVDecodingError: Error {
        case typeMismatch(CSVCodingKey)
        case valueNotFound(CSVCodingKey)
        case dataCorrupted
    }
    
    let data: [String: String]
    
    var arraySeparator: String
    
    init(data: [String: String], arraySeparator: String) {
        self.data = data
        self.arraySeparator = arraySeparator
    }
    
    
    func decode<T>(_ type: T.Type, forKey key: CSVCodingKey) throws -> T where T: LosslessStringConvertible {
        return try decode(T.self, forKey: key, with: T.init)
    }
    
    func decode<T>(_ type: T.Type, forKey key: CSVCodingKey) throws -> T where T: RawRepresentable, T.RawValue: LosslessStringConvertible {
        return try decode(T.self, forKey: key, with: { stringValue in
            guard let rawValue = T.RawValue(stringValue) else {
                return nil
            }
            return T.init(rawValue: rawValue)
        })
    }
    
    
    func decode<T>(_ type: T?.Type, forKey key: CSVCodingKey) throws -> T? where T: LosslessStringConvertible {
        return try decodeOptional(T?.self, forKey: key, with: T.init)
    }
    
    func decode<T>(_ type: T?.Type, forKey key: CSVCodingKey) throws -> T? where T: RawRepresentable, T.RawValue: LosslessStringConvertible {
        return try decodeOptional(T?.self, forKey: key, with: { stringValue in
            guard let rawValue = T.RawValue(stringValue) else {
                return nil
            }
            return T.init(rawValue: rawValue)
        })
    }
    
    
    func decode<T>(_ type: [T].Type, forKey key: CSVCodingKey) throws -> [T] where T: LosslessStringConvertible {
        return try decodeArray([T].self, forKey: key, with: T.init)
    }
    
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
            throw CSVDecodingError.valueNotFound(key)
        }
        guard let value = initializer(stringValue) else {
            throw CSVDecodingError.typeMismatch(key)
        }
        return value
    }
    
    private func decodeOptional<T>(_ type: T?.Type, forKey key: CSVCodingKey, with initializer: (String) -> T?) throws -> T? {
        guard let stringValue = data[key] else {
            // If the value does not exist, we return nil
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
            throw CSVDecodingError.valueNotFound(key)
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
