//
//  ListIconColorPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Flow
import SwiftUI

struct ListIconColorPicker: View {
    static let defaultColors: [UIColor] = [
        UIColor.redIcon,
        UIColor.orangeIcon,
        UIColor.yellowIcon,
        UIColor.greenIcon,
        UIColor.lightBlueIcon,
        UIColor.blueIcon,
        UIColor.violetIcon,
        UIColor.pinkIcon,
        UIColor.roseIcon,
        UIColor.brownIcon,
        UIColor.grayIcon,
        UIColor.lightBrownIcon,
    ]
    
    let colors: [UIColor]
    @Binding var color: UIColor
    @State private var colorIndex: Int
    
    init(colors: [UIColor] = Self.defaultColors, color: Binding<UIColor>) {
        self.colors = colors
        self._color = color
        self._colorIndex = State(wrappedValue: colors.firstIndex(of: color.wrappedValue) ?? 0)
    }
    
    var body: some View {
        HFlow(alignment: .top) {
            ForEach(Array(colors.enumerated()), id: \.1.self) { currentColorIndex, currentColor in
                ColorSwatch(color: Color(currentColor))
                    .padding(4)
                    .overlay(
                        Circle()
                            .stroke(.gray, lineWidth: 2.0)
                            .opacity(colorIndex == currentColorIndex ? 1.0 : 0.0)
                    )
                    .onTapGesture {
                        self.colorIndex = currentColorIndex
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
