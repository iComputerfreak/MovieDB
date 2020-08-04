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
