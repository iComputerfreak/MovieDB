//
//  NavigationLinkChevron.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct NavigationLinkChevron: View {
    var body: some View {
        // Imitates a NavigationLink chevron. Does not work with some accessibility settings (e.g. bigger text, bold text, magnification, ...)
        Image(systemName: "chevron.right")
            .resizable()
            .frame(width: 7, height: 11.8)
            .foregroundColor(Color(
                .displayP3,
                red: 197 / 255.0,
                green: 197 / 255.0,
                blue: 199 / 255.0,
                opacity: 1
            ))
            .font(.caption2.weight(.semibold))
    }
}

#Preview {
    NavigationLinkChevron()
}
