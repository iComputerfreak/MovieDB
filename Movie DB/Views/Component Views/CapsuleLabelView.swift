//
//  CapsuleLabelView.swift
//  Movie DB
//
//  Created by Jonas Frey on 16.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import JFUtils
import SwiftUI

struct CapsuleLabelView<Content>: View where Content: View {
    @ViewBuilder let content: () -> Content
    @Environment(\.colorScheme) private var colorScheme
    
    private let color: Color?
    private let font: Font
    private let preserveMinimumHeight: Bool
    
    init(
        text: String,
        font: Font = .caption,
        color: Color? = nil
    ) where Content == Text {
        self.init(
            color: color,
            font: font,
            preserveMinimumHeight: false,
            content: {
                Text(text)
                    .bold()
            }
        )
    }
    
    /// Creates a new capsule view with the given content
    /// - Parameters:
    ///   - preserveMinimumHeight: Whether the view should be at least as high as text of the current font size
    ///   - content: The content to display inside the capsule
    init(
        color: Color? = nil,
        font: Font = .caption,
        preserveMinimumHeight: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.color = color
        self.font = font
        self.preserveMinimumHeight = preserveMinimumHeight
        self.content = content
    }
    
    var body: some View {
        Group {
            if preserveMinimumHeight {
                ZStack {
                    Text(verbatim: "X")
                        .opacity(0)
                    content()
                }
            } else {
                content()
            }
        }
        .font(font)
        .foregroundStyle(color ?? .primary)
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(
            Capsule(style: .continuous)
            // Use a gray background, depending on the scheme
                .fill(colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.9))
        )
    }
}

#Preview {
    VStack {
        CapsuleLabelView(text: "16", color: Color.ageSixteen)
        CapsuleLabelView(text: "18", color: Color.ageEighteen)
        CapsuleLabelView(text: "Movie")
        CapsuleLabelView(text: "TV Show")
        CapsuleLabelView(text: "2023")
        CapsuleLabelView {
            CompactStarRatingView(rating: .threeAndAHalfStars)
        }
    }
}
