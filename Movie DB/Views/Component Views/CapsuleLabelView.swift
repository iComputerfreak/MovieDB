//
//  SmallLabelView.swift
//  Movie DB
//
//  Created by Jonas Frey on 16.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import JFUtils
import SwiftUI

struct CapsuleLabelView: View {
    let text: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme
    
    init(text: String, color: Color? = nil) {
        self.text = text
        self.color = color ?? .primary
    }
    
    var body: some View {
        Text(text)
            .font(.caption)
            .bold()
            .padding(.horizontal, 5)
            .padding(.vertical, 1.5)
            .background(
                Capsule(style: .continuous)
                    // Use a gray background, depending on the scheme
                    .fill(colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.9))
            )
            .foregroundColor(color)
    }
}

struct SmallLabelView_Previews: PreviewProvider {
    static var previews: some View {
        CapsuleLabelView(text: "16", color: Color("AgeSixteen"))
            .previewLayout(.fixed(width: 100, height: 80))
    }
}
