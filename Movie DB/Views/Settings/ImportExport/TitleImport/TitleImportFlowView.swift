// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TitleImportFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workflow: TitleImportWorkflow
    @State private var isShowingStopConfirmation = false

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
                        cancelAction: { isShowingStopConfirmation = true }
                    )
                case .review:
                    TitleImportReviewView(workflow: workflow)
                case .confirmation:
                    TitleImportConfirmationView(workflow: workflow)
                case .importing:
                    TitleImportFinalProgressView(
                        processedCount: workflow.finalImportProcessedCount,
                        totalCount: workflow.finalImportTotalCount,
                        cancelAction: { isShowingStopConfirmation = true }
                    )
                case .summary:
                    if let result = workflow.finalResult {
                        TitleImportSummaryView(
                            result: result,
                            retryAction: workflow.retryFailedImports,
                            finishAction: dismiss.callAsFunction
                        )
                    }
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
                        if workflow.isPerformingWork {
                            isShowingStopConfirmation = true
                        } else {
                            dismiss()
                        }
                    }
                }
            }
        }
        .task { await workflow.loadFile() }
        .confirmationDialog(
            Strings.TitleImport.StopConfirmation.title,
            isPresented: $isShowingStopConfirmation,
            titleVisibility: .visible
        ) {
            Button(Strings.TitleImport.StopConfirmation.stop, role: .destructive) {
                workflow.cancelCurrentWork()
            }
            Button(Strings.Generic.alertButtonCancel, role: .cancel) {}
        } message: {
            Text(Strings.TitleImport.StopConfirmation.message)
        }
        .interactiveDismissDisabled(workflow.isPerformingWork)
    }

    private var navigationTitle: String {
        switch workflow.stage {
        case .review: Strings.TitleImport.reviewTitle
        case .confirmation: Strings.TitleImport.Confirmation.title
        case .importing: Strings.TitleImport.FinalImport.title
        case .summary: Strings.TitleImport.Summary.title
        default: Strings.TitleImport.title
        }
    }
}

#if DEBUG
#Preview {
    TitleImportFlowView(workflow: TitleImportPreviewData.workflow())
}
#endif
