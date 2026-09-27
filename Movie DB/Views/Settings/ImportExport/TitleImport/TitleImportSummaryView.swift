// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

/// Summarizes final import outcomes and offers retry or completion actions.
struct TitleImportSummaryView: View {
    let result: TitleImportFinalResult
    let retryAction: () -> Void
    let finishAction: () -> Void

    var body: some View {
        List {
            Section {
                LabeledContent(Strings.TitleImport.Summary.imported, value: result.importedCount.description)
                LabeledContent(Strings.TitleImport.Summary.duplicates, value: result.duplicateCount.description)
                LabeledContent(Strings.TitleImport.Summary.failed, value: result.failedCount.description)
                LabeledContent(Strings.TitleImport.Summary.remaining, value: result.remainingCount.description)
            }

            if result.failedCount > 0 {
                Section {
                    Button(Strings.TitleImport.Summary.retryFailed, action: retryAction)
                        .frame(maxWidth: .infinity)
                }
            }

            Section {
                Button(Strings.TitleImport.Summary.finish, action: finishAction)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .listRowBackground(Color.clear)
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        TitleImportSummaryView(
            result: TitleImportFinalResult(
                importedCount: 18,
                duplicateCount: 1,
                failedIdentities: [MediaIdentity(type: .movie, tmdbID: 1)],
                remainingIdentities: [MediaIdentity(type: .show, tmdbID: 2)]
            ),
            retryAction: {},
            finishAction: {}
        )
        .navigationTitle(Strings.TitleImport.Summary.title)
    }
}
#endif
