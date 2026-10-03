// Copyright © 2023 Jonas Frey. All rights reserved.

import Flow
import SwiftUI

struct ListIconColorPicker: View {
    static let defaultColors: [NSUIColor] = [
        NSUIColor.primaryIcon,
        NSUIColor.redIcon,
        NSUIColor.orangeIcon,
        NSUIColor.yellowIcon,
        NSUIColor.greenIcon,
        NSUIColor.lightBlueIcon,
        NSUIColor.blueIcon,
        NSUIColor.violetIcon,
        NSUIColor.pinkIcon,
        NSUIColor.roseIcon,
        NSUIColor.brownIcon,
        NSUIColor.grayIcon,
    ]
    
    let colors: [NSUIColor]
    @Binding var color: NSUIColor
    @State private var colorIndex: Int
    
    init(colors: [NSUIColor] = Self.defaultColors, color: Binding<NSUIColor>) {
        self.colors = colors
        self._color = color
        // We compare the components, because the colors stored in Core Data have been transformed
        // and will not be equal to the dynamic instances from the asset catalog
        let selectedIndex = colors.firstIndex(where: \.components, equals: color.wrappedValue.components)
        self._colorIndex = State(wrappedValue: selectedIndex ?? 0)
    }
    
    var body: some View {
        HFlow(alignment: .top) {
            ForEach(Array(colors.enumerated()), id: \.1.self) { currentColorIndex, currentColor in
                ColorSwatch(color: Color(currentColor))
                    .accessibilityIdentifier("color\(currentColorIndex)")
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
    @Previewable @State var color: NSUIColor = .red
    
    return List {
        HStack {
            Spacer(minLength: 0)
            ListIconColorPicker(color: $color)
            Spacer(minLength: 0)
        }
    }
}
