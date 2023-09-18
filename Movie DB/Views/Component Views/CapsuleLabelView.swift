//
//  SmallLabelView.swift
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
    
    init(text: String, color: Color? = nil) where Content == Text {
        self.content = {
            Text(text)
                .font(.caption)
                .bold()
                .foregroundColor(color ?? .primary)
        }
    }
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(.horizontal, 5)
            .padding(.vertical, 1.5)
            .background(
                Capsule(style: .continuous)
                    // Use a gray background, depending on the scheme
                    .fill(colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.9))
            )
    }
}

struct SmallLabelView_Previews: PreviewProvider {
    static var previews: some View {
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
}
