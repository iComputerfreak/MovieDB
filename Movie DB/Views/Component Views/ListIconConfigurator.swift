//
//  ListIconConfigurator.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ListIconConfigurator: View {
    @Binding var name: String
    @Binding var iconName: String
    @Binding var iconColor: UIColor
    @Binding var iconMode: IconRenderingMode
    
    var symbolRenderingModes: [SymbolRenderingMode] {
        [.multicolor, .palette, .hierarchical, .monochrome]
    }
    
    var body: some View {
        List {
            // MARK: Icon and Name
            Section {
                VStack {
                    ListIconPreview(name: name, iconName: iconName, iconColor: iconColor)
                        .symbolRenderingMode(iconMode.symbolRenderingMode)
                        .padding(.bottom)
                    // TODO: Localize
                    TextField("List Name", text: $name)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.calloutBackground))
                }
                .padding(.vertical)
            }
            Section {
                Picker(selection: $iconMode) {
                    ForEach(IconRenderingMode.allCases, id: \.rawValue) { mode in
                        Text(mode.localized)
                            .tag(mode)
                    }
                } label: {
                    // TODO: Localize
                    Text("Color Mode")
                }
            }
            // MARK: Color
            Section {
                ListIconColorPicker(color: $iconColor)
            }
            // MARK: Icon
            Section {
                ListIconPicker(symbolName: $iconName)
                    .symbolRenderingMode(iconMode.symbolRenderingMode)
                    .padding(.horizontal, 0)
            }
        }
        .symbolVariant(.fill)
    }
}

#Preview {
    @State var listName = "Dynamic List"
    @State var iconName = "music.note"
    @State var iconColor: UIColor? = nil
    @State var iconMode: IconRenderingMode = .multicolor
    
    return ListIconConfigurator(
        name: $listName,
        iconName: $iconName,
        iconColor: Binding($iconColor, defaultValue: .label),
        iconMode: $iconMode
    )
}
