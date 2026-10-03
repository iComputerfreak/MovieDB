// Copyright © 2026 Jonas Frey. All rights reserved.

#if canImport(UIKit)
import UIKit
/// The platform-native color type.
public typealias NSUIColor = UIColor
/// The platform-native image type.
public typealias NSUIImage = UIImage
/// The platform-native view representable type
public typealias PlatformViewRepresentable = UIViewRepresentable
#elseif canImport(AppKit)
import AppKit
/// The platform-native color type.
public typealias NSUIColor = NSColor
/// The platform-native image type.
public typealias NSUIImage = NSImage
/// The platform-native view representable type
public typealias PlatformViewRepresentable = NSViewRepresentable
#endif

import SwiftUI

#if canImport(AppKit)

@available(iOS 13.0, *)
public extension Color {
    /// The system's background color
    static let systemBackground = Color(NSColor.windowBackgroundColor)
}

public extension NSColor {
    /// Returns the red, green, blue, and alpha components of this color
    var components: [CGFloat] {
        guard let rgbColor = usingColorSpace(.deviceRGB) else { return [0, 0, 0, 0] }
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue, alpha]
    }
}

#endif

public extension NSUIImage {
    /// Creates a platform image from a Core Graphics image.
    /// - Parameter cgImage: Source bitmap image.
    /// - Returns: Platform-native image.
    static func from(cgImage: CGImage) -> NSUIImage {
        #if canImport(UIKit)
        NSUIImage(cgImage: cgImage)
        #elseif canImport(AppKit)
        NSUIImage(cgImage: cgImage, size: .zero)
        #endif
    }

    /// Core Graphics representation used for image cost calculations.
    var platformCGImage: CGImage? {
        #if canImport(UIKit)
        cgImage
        #elseif canImport(AppKit)
        cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
    }

    /// PNG-encoded image data.
    var pngDataRepresentation: Data? {
        #if canImport(UIKit)
        pngData()
        #elseif canImport(AppKit)
        guard let tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmap.representation(using: .png, properties: [:])
        #endif
    }
}

public extension Image {
    /// Creates a SwiftUI image from a platform-native image.
    /// - Parameter platformImage: Platform image to display.
    init(platformImage: NSUIImage) {
        #if canImport(UIKit)
        self.init(uiImage: platformImage)
        #elseif canImport(AppKit)
        self.init(nsImage: platformImage)
        #endif
    }
}
