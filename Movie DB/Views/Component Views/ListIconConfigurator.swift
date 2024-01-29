//
//  ListIconConfigurator.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ListIconConfigurator<Content: View>: View {
    @Binding var name: String
    @Binding var iconName: String
    @Binding var iconColor: UIColor
    @Binding var iconMode: IconRenderingMode
    var configurationSection: Content
    
    var symbolRenderingModes: [SymbolRenderingMode] {
        [.multicolor, .palette, .hierarchical, .monochrome]
    }
    
    init(
        name: Binding<String>,
        iconName: Binding<String>,
        iconColor: Binding<UIColor>,
        iconMode: Binding<IconRenderingMode>,
        @ViewBuilder configurationSection: () -> Content
    ) {
        self._name = name
        self._iconName = iconName
        self._iconColor = iconColor
        self._iconMode = iconMode
        self.configurationSection = configurationSection()
    }
    
    init(
        name: Binding<String>,
        iconName: Binding<String>,
        iconColor: Binding<UIColor?>,
        iconMode: Binding<IconRenderingMode>,
        @ViewBuilder configurationSection: () -> Content
    ) {
        self.init(
            name: name,
            iconName: iconName,
            iconColor: Binding(iconColor, defaultValue: .primaryIcon),
            iconMode: iconMode,
            configurationSection: configurationSection
        )
    }
    
    var body: some View {
        List {
            // MARK: Icon and Name
            Section {
                VStack {
                    ListIconPreview(name: name, iconName: iconName, iconColor: iconColor)
                        .symbolRenderingMode(iconMode.symbolRenderingMode)
                        .padding(.bottom)
                    TextField(text: $name) {
                        Text(
                            "lists.configuration.listName",
                            comment: "The label of the text field that the user enters a list's name in."
                        )
                    }
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.calloutBackground))
                }
                .padding(.vertical)
            }
            configurationSection
            Section {
                Picker(selection: $iconMode) {
                    ForEach(IconRenderingMode.allCases, id: \.rawValue) { mode in
                        Text(mode.localized)
                            .tag(mode)
                    }
                } label: {
                    Text(
                        "lists.configuration.iconRenderingMode",
                        comment: "The label for the picker that the user uses to select an icon rendering mode."
                    )
                }
                // MARK: Color
                ListIconColorPicker(color: $iconColor)
                    .frame(maxWidth: .infinity)
            } header: {
                Text(
                    "lists.configuration.header.iconColor",
                    // swiftlint:disable:next line_length
                    comment: "The header of the configuration section that lets the user define the icon color settings."
                )
            }
            // MARK: Icon Picker
            Section {
                ListIconPicker(symbolName: $iconName)
                    .symbolRenderingMode(iconMode.symbolRenderingMode)
                    .padding(.horizontal, 0)
            } header: {
                Text(
                    "lists.configuration.header.icon",
                    comment: "The header of the configuration section that lets the user choose the icon for a list."
                )
            }
        }
        .symbolVariant(.fill)
        .navigationBarTitleDisplayMode(.inline)
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
        iconColor: $iconColor,
        iconMode: $iconMode
    ) {
        Section {
            Toggle(isOn: .constant(true)) {
                Text(verbatim: "Toggle")
            }
        } header: {
            Text(verbatim: "Header")
        }
    }
}
