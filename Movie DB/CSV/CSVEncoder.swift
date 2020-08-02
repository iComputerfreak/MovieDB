//
//  CSVEncoder.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

struct CSVEncoder {
    
    var data: [String: String]
    
    var arraySeparator: String
    
    init(arraySeparator: String) {
        self.data = [:]
        self.arraySeparator = arraySeparator
    }
    
    mutating func encode<T>(_ value: T, forKey key: CSVCodingKey) where T: LosslessStringConvertible {
        data[key] = value.description
    }
    
    mutating func encode<T>(_ value: T, forKey key: CSVCodingKey) where T: RawRepresentable, T.RawValue: LosslessStringConvertible {
        data[key] = value.rawValue.description
    }
    
    
    mutating func encode<T>(_ value: T?, forKey key: CSVCodingKey) where T: LosslessStringConvertible {
        data[key] = value?.description
    }
    
    mutating func encode<T>(_ value: T?, forKey key: CSVCodingKey) where T: RawRepresentable, T.RawValue: LosslessStringConvertible {
        data[key] = value?.rawValue.description
    }
    
    
    mutating func encode<T>(_ value: [T], forKey key: CSVCodingKey) where T: LosslessStringConvertible {
        data[key] = value.map(\.description).joined(separator: arraySeparator)
    }
    
    mutating func encode<T>(_ value: [T], forKey key: CSVCodingKey) where T: RawRepresentable, T.RawValue: LosslessStringConvertible {
        data[key] = value.map(\.rawValue.description).joined(separator: arraySeparator)
    }
    
}
