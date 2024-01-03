//
//  ListIconColorPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ListIconColorPicker: View {
    private static let defaultColors: [UIColor] = [
        UIColor.label, .accent, .red, .orange, .yellow, .green, .blue, .purple, .brown, .gray,
    ]
    
    let colors: [UIColor]
    @Binding var color: UIColor
    
    init(colors: [UIColor] = Self.defaultColors, color: Binding<UIColor>) {
        self.colors = colors
        self._color = color
    }
    
    var body: some View {
        WrappingHStack(alignment: .leading) {
            ForEach(colors, id: \.self) { currentColor in
                ColorSwatch(color: Color(currentColor))
                    .padding(4)
                    .overlay(
                        Circle()
                            .stroke(.gray, lineWidth: 2.0)
                            .opacity(currentColor == self.color ? 1.0 : 0.0)
                    )
                    .onTapGesture {
                        self.color = currentColor
                    }
            }
        }
        .padding(.horizontal, 0)
    }
}

struct ColorSwatch: View {
    let size: CGFloat = 35
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}

#Preview {
    @State var color: UIColor = .red
    
    return List {
        HStack {
            Spacer(minLength: 0)
            ListIconColorPicker(color: $color)
            Spacer(minLength: 0)
        }
    }
}
