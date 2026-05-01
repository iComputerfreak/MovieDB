// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct ScreenLoadingView: View {
    let title: String?
    let message: String

    init(title: String? = nil, message: String = Strings.Generic.loadingText) {
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .navigationTitle(title ?? "")
    }
}

#Preview {
    NavigationStack {
        ScreenLoadingView(title: Strings.Generic.navBarLoadingTitle)
    }
    .previewEnvironment()
}
