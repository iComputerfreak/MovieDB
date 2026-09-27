// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

/// Displays final media-creation progress and an action to stop remaining work.
struct TitleImportFinalProgressView: View {
    let processedCount: Int
    let totalCount: Int
    let cancelAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ProgressView(value: Double(processedCount), total: Double(max(totalCount, 1)))
                .progressViewStyle(.linear)
            Text(Strings.TitleImport.FinalImport.progress(processedCount, totalCount))
                .monospacedDigit()
                .foregroundStyle(.secondary)
            Button(Strings.TitleImport.FinalImport.stop, role: .destructive, action: cancelAction)
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    TitleImportFinalProgressView(processedCount: 7, totalCount: 20, cancelAction: {})
}
#endif
