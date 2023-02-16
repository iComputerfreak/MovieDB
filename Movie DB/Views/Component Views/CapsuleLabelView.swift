//
//  SmallLabelView.swift
//  Movie DB
//
//  Created by Jonas Frey on 16.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct CapsuleLabelView: View {
    let text: String
    let color: Color
    
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
                    .fill(.tertiary)
            )
            .foregroundColor(color)
    }
}

struct SmallLabelView_Previews: PreviewProvider {
    static var previews: some View {
        CapsuleLabelView(text: "16", color: Color("AgeSixteen"))
    }
}
