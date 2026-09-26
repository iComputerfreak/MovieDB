// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TitleImportFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workflow: TitleImportWorkflow

    init(workflow: TitleImportWorkflow) {
        _workflow = State(initialValue: workflow)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch workflow.stage {
                case .loading:
                    ProgressView(Strings.TitleImport.loadingFile)
                case .preflight:
                    if let preflight = workflow.preflight {
                        TitleImportPreflightView(preflight: preflight, startAction: workflow.startResolution)
                    }
                case .resolving:
                    TitleImportProgressView(
                        processedCount: workflow.processedCount,
                        totalCount: workflow.totalCount,
                        cancelAction: workflow.cancelResolution
                    )
                case .review:
                    TitleImportReviewView(workflow: workflow)
                case .failure:
                    ScreenUnavailableView(
                        title: Strings.TitleImport.Error.title,
                        systemImage: "exclamationmark.triangle",
                        description: workflow.error?.localizedDescription,
                        actionTitle: Strings.Generic.retryLoading,
                        action: workflow.retryLoading
                    )
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Strings.Generic.dismissViewDone) {
                        workflow.cancelResolution()
                        dismiss()
                    }
                }
            }
        }
        .task { await workflow.loadFile() }
        .interactiveDismissDisabled(workflow.stage == .resolving)
    }

    private var navigationTitle: String {
        switch workflow.stage {
        case .review: Strings.TitleImport.reviewTitle
        default: Strings.TitleImport.title
        }
    }
}
