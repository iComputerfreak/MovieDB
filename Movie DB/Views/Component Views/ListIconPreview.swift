//
//  ListIconPreview.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ListIconPreview: View {
    let name: String
    let iconName: String
    let iconColor: UIColor?
    
    var color: Color? {
        if let iconColor {
            return Color(iconColor)
        }
        return .accentColor
    }
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 60, maxHeight: 60)
                .foregroundColor(color)
                .padding()
                .background(Circle().fill(Color.calloutBackground))
            Spacer()
        }
    }
}

#Preview {
    List {
        ListIconPreview(
            name: "Dynamic List",
            iconName: "music.note",
            iconColor: .red
        )
    }
}
