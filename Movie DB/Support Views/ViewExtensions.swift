//
//  ViewExtensions.swift
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
    init(get: @escaping () -> Value) {
        self.init(get: get, set: { _ in })
    }
}
