// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

/// Summarizes final import outcomes and offers retry or completion actions.
struct TitleImportSummaryView: View {
    @State private var isShowingReportExporter = false

    let result: TitleImportFinalResult
    let reportData: Data?
    let reportFilename: String
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

            if reportData != nil {
                Section {
                    Button {
                        isShowingReportExporter = true
                    } label: {
                        Label(Strings.TitleImport.Summary.exportReport, systemImage: "square.and.arrow.up")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .fileExporter(
            isPresented: $isShowingReportExporter,
            item: reportData,
            defaultFilename: reportFilename,
            onCompletion: { _ in }
        )
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(Strings.TitleImport.Summary.finish, role: .legacyConfirm, action: finishAction)
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
                importedIdentities: [MediaIdentity(type: .movie, tmdbID: 3)],
                duplicateIdentities: [MediaIdentity(type: .movie, tmdbID: 4)],
                failedIdentities: [MediaIdentity(type: .movie, tmdbID: 1)],
                remainingIdentities: [MediaIdentity(type: .show, tmdbID: 2)]
            ),
            reportData: Data("report".utf8),
            reportFilename: "MovieDB_Title_Import_Report.csv",
            retryAction: {},
            finishAction: {}
        )
        .navigationTitle(Strings.TitleImport.Summary.title)
    }
}
#endif
