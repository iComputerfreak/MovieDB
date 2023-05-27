//
//  Extensions.swift
//  Movie DB
//
//  Created by Jonas Frey on 18.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

public extension KeyedDecodingContainer {
    /// Tries to decode a value with any of the given keys
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode
    ///   - keys: The array of keys that the value may be associated with
    /// - Returns: The value associated with the first matching key that is not `nil`
    /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    /// - Throws: `DecodingError.keyNotFound` if `self` does not have an non-nil entry
    ///   for any of the given keys.
    func decodeAny<T>(_: T.Type, forKeys keys: [Self.Key]) throws -> T where T: Decodable {
        for key in keys {
            if let value = try decodeIfPresent(T.self, forKey: key) {
                return value
            }
        }
        let context = DecodingError.Context(
            codingPath: codingPath,
            debugDescription: "No value associated with any of the keys \(keys)"
        )
        throw DecodingError.keyNotFound(keys.first!, context)
    }
}

public extension UnkeyedDecodingContainer {
    /// Tries to decode an array
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode
    /// - Returns: The array of values associated with this unkeyed container
    /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    mutating func decodeArray<T>(_: T.Type) throws -> [T] where T: Decodable {
        var returnValues = [T]()
        
        while !isAtEnd {
            try returnValues.append(decode(T.self))
        }
        
        return returnValues
    }
}

extension [String: Any?] {
    /// Returns the dictionary as a string of HTTP arguments, percent escaped
    ///
    ///     [key1: "test", key2: "Hello World"].percentEscaped()
    ///     // Returns "key1=test&key2=Hello%20World"
    func percentEscaped() -> String {
        map { key, value in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value ?? "null")"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
}

extension CharacterSet {
    /// Returns the set of characters that are allowed in a URL query
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
}

extension NSSecureUnarchiveFromDataTransformer {
    static var name: NSValueTransformerName { .init(rawValue: String(describing: Self.self)) }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            Self(),
            forName: Self.name
        )
    }
}

struct LastNameComparator: SortComparator {
    typealias Compared = String
    
    var order: SortOrder
    
    func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let lhsLastName = lhs.components(separatedBy: .whitespaces).last
        let rhsLastName = rhs.components(separatedBy: .whitespaces).last
        
        guard lhsLastName != rhsLastName else {
            return .orderedSame
        }
        
        guard let lhsLastName, !lhsLastName.isEmpty else {
            return .orderedDescending
        }
        guard let rhsLastName, !rhsLastName.isEmpty else {
            return .orderedAscending
        }
        
        // Sort by last name
        return lhsLastName.compare(rhsLastName)
    }
}

extension NSPredicate {
    /// Returns a negated version of this predicate
    func negated() -> NSPredicate {
        NSCompoundPredicate(type: .not, subpredicates: [self])
    }
}

extension Int {
    /// Pads this number by adding the given paddingString to the left, until a given length is reached
    /// - Parameters:
    ///   - length: The minimum length of the resulting string
    ///   - paddingString: The string to use for the padding
    /// - Returns: The padded string
    func padding(toLength length: Int, withPad paddingString: String = " ") -> String {
        var string = String(self)
        
        while string.count < length {
            string = paddingString + string
        }
        
        return string
    }
}

extension UIColor {
    /// Returns the red, green, blue, and alpha components of this color
    var components: [CGFloat] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue, alpha]
    }
}

extension View {
    /// Prepares the view for executing in a preview environment.
    ///
    /// **Not intended for production use!**
    func previewEnvironment() -> some View {
        self
            .environment(\.managedObjectContext, PersistenceController.previewContext)
            .environmentObject(JFConfig.shared)
            .environmentObject(StoreManager.shared)
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
        // Will not work, but will prevent the preview from crashing
            .environmentObject(NotificationProxy())
    }
}

// TODO: Move into JFUtils
extension Collection {
    func first<T: Equatable>(where keyPath: KeyPath<Element, T>, equals other: T) -> Element? {
        return first { element in
            element[keyPath: keyPath] == other
        }
    }
    
    func firstIndex<T: Equatable>(where keyPath: KeyPath<Element, T>, equals other: T) -> Index? {
        return firstIndex { element in
            element[keyPath: keyPath] == other
        }
    }
}
