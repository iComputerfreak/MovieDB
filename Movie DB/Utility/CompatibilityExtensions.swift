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

public extension View {
    /// Uses an inline navigation title on iOS and the platform default elsewhere.
    /// - Returns: The platform-configured view.
    @ViewBuilder
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    /// Uses a large navigation title on iOS and the platform default elsewhere.
    /// - Returns: The platform-configured view.
    @ViewBuilder
    func largeNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.large)
        #else
        self
        #endif
    }

    /// Uses grouped list styling on iOS and the platform default elsewhere.
    /// - Returns: The platform-configured view.
    @ViewBuilder
    func groupedListStyle() -> some View {
        #if os(iOS)
        listStyle(.grouped)
        #else
        listStyle(.automatic)
        #endif
    }

    /// Uses inset-grouped list styling on iOS and the platform default elsewhere.
    /// - Returns: The platform-configured view.
    @ViewBuilder
    func insetGroupedListStyle() -> some View {
        #if os(iOS)
        listStyle(.insetGrouped)
        #else
        listStyle(.automatic)
        #endif
    }
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

public extension Color {
    /// Creates a SwiftUI color from a platform-native color.
    /// - Parameter platformColor: Platform color to convert.
    init(platformColor: NSUIColor) {
        #if canImport(UIKit)
        self.init(uiColor: platformColor)
        #elseif canImport(AppKit)
        self.init(nsColor: platformColor)
        #endif
    }
}

#if canImport(AppKit)
public extension View {
    /// A compatibility modifier that presents as a normal sheet on macOS
    func fullScreenCover<Content>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ContentBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        sheet(isPresented: isPresented, onDismiss: onDismiss, content: content)
    }

    /// A compatibility modifier that presents as a normal sheet on macOS
    func fullScreenCover<Item, Content>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ContentBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable, Content: View {
        sheet(item: item, onDismiss: onDismiss, content: content)
    }
}
#endif

// TODO: Rework, probably too large, unify
@available(macOS 14, *)
public struct LoadingView<Content>: View where Content: View {
    public let text: String
    @Binding public var isShowing: Bool
    public var content: () -> Content

    public init(isShowing: Binding<Bool>, text: String? = nil, content: @escaping () -> Content) {
        self.text = text ?? "Loading..."
        self._isShowing = isShowing
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)

                ProgressView {
                    Text(text)
                        .multilineTextAlignment(.center)
                }
                .frame(
                    width: geometry.size.width / 2,
                    height: geometry.size.height / 5
                )
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}
