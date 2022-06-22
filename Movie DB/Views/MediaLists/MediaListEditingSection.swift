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
    
    var body: some View {
        Section("List Information") {
            TextField("Name", text: $name)
            NavigationLink {
                SFSymbolPicker(symbol: $iconName)
            } label: {
                HStack {
                    Text("Icon")
                    Spacer()
                    Image(systemName: iconName)
                        .symbolRenderingMode(.multicolor)
                }
            }
        }
    }
}

struct MediaListEditingSection_Previews: PreviewProvider {
    static var previews: some View {
        MediaListEditingSection(name: .constant("Test"), iconName: .constant("heart.fill"))
    }
}