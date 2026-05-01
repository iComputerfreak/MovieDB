// Copyright © 2019 Jonas Frey. All rights reserved.

import Foundation
import SwiftUI

extension Image {
    /// Modifies the image to be of a pre-set thumbnail size
    /// - Parameter multiplier: A multiplier value applied to the thumbnail size
    /// - Returns: The image resized to a thumbnail
    func thumbnail(multiplier: CGFloat = 1.0) -> some View {
        resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: JFLiterals.thumbnailSize.width * multiplier,
                height: JFLiterals.thumbnailSize.height * multiplier,
                alignment: .center
            )
            .shadow(radius: 3, y: 3.5)
    }
}

/// Adds a headline view above the content
struct HeadlineModifier: ViewModifier {
    let title: Text
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            title
                .font(.caption)
                .foregroundColor(.primary)
            content
        }
    }
}

extension View {
    /// Adds a headline view above this view with the given title
    /// - Parameter title: The title to use for the headline
    func headline(_ title: Text) -> some View {
        self.modifier(HeadlineModifier(title: title))
    }

    /// Adds a headline view above this view with the given title
    /// - Parameter title: The title to use for the headline
    func headline(_ title: String) -> some View {
        self.headline(Text(title))
    }

    /// Adds a headline view above this view with the given title
    /// - Parameter title: The title to use for the headline
    func headline(verbatim title: String) -> some View {
        self.headline(Text(verbatim: title))
    }

    /// Adds a headline view above this view with the given title and leading image
    /// - Parameter image: The image to display as an icon before the headline
    /// - Parameter title: The title to use for the headline
    func headline(_ image: Image, _ title: String) -> some View {
        self.headline(Text("\(image) \(title)"))
    }

    /// Adds a headline view above this view with the given title and leading image
    /// - Parameter systemImage: The system image name to display as an icon before the headline
    /// - Parameter title: The title to use for the headline
    func headline(_ systemImage: String, _ title: String) -> some View {
        self.headline(Image(systemName: systemImage), title)
    }
}
