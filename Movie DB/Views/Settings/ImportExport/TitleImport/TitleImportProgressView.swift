// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

/// Displays candidate-resolution progress and an action to stop the operation.
struct TitleImportProgressView: View {
    let processedCount: Int
    let totalCount: Int

    var body: some View {
        VStack(spacing: 24) {
            ProgressView(value: Double(processedCount), total: Double(max(totalCount, 1)))
                .progressViewStyle(.linear)
            Text(Strings.TitleImport.Progress.resolving(processedCount, totalCount))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    TitleImportProgressView(processedCount: 38, totalCount: 120)
}
#endif
