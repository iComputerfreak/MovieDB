//
//  WatchedLabel.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct WatchedLabel: View {
    let labelText: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        (
            Text(Image(systemName: systemImage)) +
                Text(verbatim: " ") +
                Text(labelText)
        )
        .foregroundColor(color)
    }
}

#Preview {
    WatchedLabel(labelText: "Watched", systemImage: "checkmark.circle.fill", color: .green)
}
