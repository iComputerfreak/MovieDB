// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TitleImportProgressView: View {
    let processedCount: Int
    let totalCount: Int
    let cancelAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ProgressView(value: Double(processedCount), total: Double(max(totalCount, 1)))
                .progressViewStyle(.linear)
            Text(Strings.TitleImport.Progress.resolving(processedCount, totalCount))
                .monospacedDigit()
                .foregroundStyle(.secondary)
            Button(Strings.Generic.alertButtonCancel, role: .cancel, action: cancelAction)
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    TitleImportProgressView(processedCount: 38, totalCount: 120, cancelAction: {})
}
#endif
