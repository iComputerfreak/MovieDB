// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct UserDataCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        InsetCardView {
            VStack(alignment: .leading, spacing: 12) {
                Label(title, systemImage: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                content
            }
        }
    }
}

#Preview {
    UserDataCard(title: "Title", systemImage: "gear") {
        Text(verbatim: "Content")
    }
    .padding()
    .background(.gray)
}
