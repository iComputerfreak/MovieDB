// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct UserDataWatchedSummaryView: View {
    let summary: String
    let isShowingChevron: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(summary)
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            if isShowingChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
