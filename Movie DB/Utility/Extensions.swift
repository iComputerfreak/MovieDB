//
//  Extensions.swift
//  Movie DB
//
//  Created by Jonas Frey on 18.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

extension Image {
    /// Creates an Image View using the given image, or the default image, if the first didn't exist.
    /// - Parameter name: The image to use for the view
    /// - Parameter defaultImage: The fallback image name, to use when the image `name` didn't exist
    init(_ name: String, defaultImage: String) {
        if let img = UIImage(named: name) {
            self.init(uiImage: img)
        } else {
            self.init(defaultImage)
        }
    }
    
    /// Creates an Image View using the given image, or a default icon, if the first didn't exist.
    /// - Parameter name: The image to use for the view
    /// - Parameter defaultImage: The fallback icon name, to use when the image `name` didn't exist
    init(_ name: String, defaultSystemImage: String) {
        if let img = UIImage(named: name) {
            self.init(uiImage: img)
        } else {
            self.init(systemName: defaultSystemImage)
        }
    }
    
    /// Creates an Image View using the given image, or a default image, if the first didn't exist.
    /// - Parameter name: The image to use for the view
    /// - Parameter defaultImage: The fallback image name, to use when the image `name` didn't exist
    init(uiImage: UIImage?, defaultImage: String) {
        if let image = uiImage {
            self.init(uiImage: image)
        } else {
            self.init(defaultImage)
        }
    }
    
    /// Creates an Image View using the given image, or a default icon, if the first didn't exist.
    /// - Parameter name: The image to use for the view
    /// - Parameter defaultImage: The fallback icon name, to use when the image `name` didn't exist
    init(uiImage: UIImage?, defaultSystemImage: String) {
        if let image = uiImage {
            self.init(uiImage: image)
        } else {
            self.init(systemName: defaultSystemImage)
        }
    }
}

extension View {
    /// Conditionally hides the view
    /// - Parameter condition: The condition, whether to hide the view
    /// - Returns: A type-erased view, that may be hidden
    func hidden(condition: Bool) -> some View {
        if condition {
            return AnyView(self.hidden())
        } else {
            return AnyView(self)
        }
    }
    
    /// Returns a closure, returning self
    ///
    /// Used when providing a single View as label where the argument requires a closure, not a View
    func closure() -> (() -> Self) {
        return { self }
    }
}

extension Binding {
    /// Creates a get-only Binding
    /// - Parameter get: The getter of the binding
    init(get: @escaping () -> Value) {
        self.init(get: get, set: { _ in })
    }
}

extension KeyedDecodingContainer {
    
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
    public func decodeAny<T>(_ type: T.Type, forKeys keys: [Self.Key]) throws -> T where T: Decodable {
        for key in keys {
            if let value = try decodeIfPresent(T.self, forKey: key) {
                return value
            }
        }
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "No value associated with any of the keys \(keys)")
        throw DecodingError.keyNotFound(keys.first!, context)
    }
}

extension UnkeyedDecodingContainer {
    /// Tries to decode an array
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode
    /// - Returns: The array of values associated with this unkeyed container
    /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    public mutating func decodeArray<T>(_ type: T.Type) throws -> [T] where T: Decodable {
        var returnValues = [T]()
        
        while !self.isAtEnd {
            returnValues.append(try self.decode(T.self))
        }
        
        return returnValues
    }
}

extension Dictionary where Key == String, Value == Any? {
    /// Returns the dictionary as a string of HTTP arguments, percent escaped
    ///
    ///     [key1: "test", key2: "Hello World"].percentEscaped()
    ///     // Returns "key1=test&key2=Hello%20World"
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value ?? "null")".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
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

extension String {
    /// Returns a string without a given prefix
    ///
    ///     "abc def".removingPrefix("abc") // returns " def"
    ///     "cba def".revmoingPrefix("abc") // returns "cba def"
    ///
    /// - Parameter prefix: The prefix to remove, if it exists
    /// - Returns: The string without the given prefix
    func removingPrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) {
            return String(self.dropFirst(prefix.count))
        }
        // If the prefix does not exist, leave the string as it is
        return String(self)
    }
    /// Returns a string without a given suffix
    ///
    ///     "abc def".removingSuffix("def") // returns "abc "
    ///     "abc fed".revmoingSuffix("def") // returns "abc fed"
    ///
    /// - Parameter suffix: The suffix to remove, if it exists
    /// - Returns: The string without the given suffix
    func removingSuffix(_ suffix: String) -> String {
        if self.hasSuffix(suffix) {
            return String(self.dropLast(suffix.count))
        }
        // If the prefix does not exist, leave the string as it is
        return String(self)
    }
    /// Removes a prefix from a string
    ///
    ///     let a = "abc def".removingPrefix("abc") // a is " def"
    ///     let b = "cba def".revmoingPrefix("abc") // b is "cba def"
    ///
    /// - Parameter prefix: The prefix to remove, if it exists
    /// - Returns: The string without the given prefix
    mutating func removePrefix(_ prefix: String) {
        if self.hasPrefix(prefix) {
            self.removeFirst(prefix.count)
        }
        // If the prefix does not exist, leave the string as it is
    }
    /// Removes a suffix from a string
    ///
    ///     let a = "abc def".removingSuffix("def") // a is "abc "
    ///     let b = "abc fed".revmoingSuffix("def") // b is "abc fed"
    ///
    /// - Parameter suffix: The suffix to remove, if it exists
    /// - Returns: The string without the given suffix
    mutating func removeSuffix(_ suffix: String) {
        if self.hasSuffix(suffix) {
            self.removeLast(suffix.count)
        }
        // If the prefix does not exist, leave the string as it is
    }
}

extension NumberFormatter {
    func string(from value: Double) -> String? {
        return self.string(from: NSNumber(value: value))
    }
    
    func string(from value: Int) -> String? {
        return self.string(from: NSNumber(value: value))
    }
}

extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
}
