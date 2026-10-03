// Copyright © 2026 Jonas Frey. All rights reserved.

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Writes plain text to the platform pasteboard.
@MainActor
enum Clipboard {
    /// Copies plain text to the general pasteboard.
    /// - Parameter string: Text to copy.
    static func copy(_ string: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = string
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        #endif
    }
}
