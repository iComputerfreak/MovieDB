//
//  CSVCoder.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

protocol Importable {
    init(from importer: Importer) throws
}

protocol Importer {
    /// The path of coding keys taken to get to this point in importing.
    var codingPath: [CodingKey] { get }
    
    /// Any contextual information set by the user for decoding.
    var userInfo: [CodingUserInfoKey : Any] { get }
    
    /// Returns the data stored in this importer as represented in a container
    /// keyed by the given key type.
    ///
    /// - parameter type: The key type to use for the container.
    /// - returns: A keyed decoding container view into this importer.
    /// - throws: `DecodingError.typeMismatch` if the encountered stored value is
    ///   not a keyed container.
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedImportingContainer<Key> where Key : CodingKey
    
    /// Returns the data stored in this importer as represented in a container
    /// appropriate for holding values with no keys.
    ///
    /// - returns: An unkeyed container view into this importer.
    /// - throws: `DecodingError.typeMismatch` if the encountered stored value is
    ///   not an unkeyed container.
    func unkeyedContainer() throws -> UnkeyedImportingContainer
    
    /// Returns the data stored in this importer as represented in a container
    /// appropriate for holding a single primitive value.
    ///
    /// - returns: A single value container view into this importer.
    /// - throws: `DecodingError.typeMismatch` if the encountered stored value is
    ///   not a single value container.
    func singleValueContainer() throws -> SingleValueDecodingContainer
}

struct KeyedImportingContainer<Key> where K: CodingKey {
    
}

struct Test: Importable {
    
}
