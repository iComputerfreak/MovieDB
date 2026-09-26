// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TitleImportStatusLabel: View {
    let status: TitleImportReviewStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text(label)
        }
        .font(.caption.bold())
        .foregroundStyle(color)
    }

    private var label: String {
        switch status {
        case .accepted: Strings.TitleImport.Status.accepted
        case .ambiguous: Strings.TitleImport.Status.ambiguous
        case .duplicate: Strings.TitleImport.Status.duplicate
        case .noMatch: Strings.TitleImport.Status.noMatch
        case .failed: Strings.TitleImport.Status.failed
        }
    }

    private var systemImage: String {
        switch status {
        case .accepted: "checkmark.circle.fill"
        case .ambiguous: "questionmark.circle.fill"
        case .duplicate: "doc.on.doc.fill"
        case .noMatch: "magnifyingglass"
        case .failed: "exclamationmark.triangle.fill"
        }
    }

    private var color: Color {
        switch status {
        case .accepted: .green
        case .ambiguous: .orange
        case .duplicate: .blue
        case .noMatch: .secondary
        case .failed: .red
        }
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(TitleImportReviewStatus.allCases, id: \.self) { status in
            TitleImportStatusLabel(status: status)
        }
    }
    .padding()
}
#endif
