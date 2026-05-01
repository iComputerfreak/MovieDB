// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct SettingsActionLabel: View {
    let title: String
    let systemImage: String
    var tint: Color = .accentColor

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 9))

            Text(title)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
    }
}
