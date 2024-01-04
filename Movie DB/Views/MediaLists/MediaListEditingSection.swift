//
//  MediaListEditingSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct MediaListEditingSection: View {
    @Binding var name: String
    @Binding var iconName: String
    @Binding var iconColor: UIColor
    @Binding var iconMode: IconRenderingMode
    
    var body: some View {
        Section(Strings.Lists.editingInformationHeader) {
            TextField(Strings.Lists.editingNameLabel, text: $name)
            NavigationLink {
                ListIconConfigurator(name: $name, iconName: $iconName, iconColor: $iconColor, iconMode: $iconMode)
            } label: {
                HStack {
                    Text(Strings.Lists.editingIconLabel)
                    Spacer()
                    Image(systemName: iconName)
                        .symbolRenderingMode(.multicolor)
                }
            }
        }
    }
}

#Preview {
    MediaListEditingSection(
        name: .constant("Test"),
        iconName: .constant("heart.fill"),
        iconColor: .constant(UIColor.red),
        iconMode: .constant(.multicolor)
    )
}
