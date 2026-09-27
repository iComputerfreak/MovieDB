// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

/// Presents the stage-driven container for the complete title-import flow.
struct TitleImportFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workflow: TitleImportWorkflow
    @State private var isShowingStopConfirmation = false
    @State private var isShowingDismissalConfirmation = false

    /// Creates the flow around an existing workflow instance.
    /// - Parameter workflow: The workflow whose state drives navigation and actions.
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
                    if let preflight = Binding($workflow.preflight) {
                        TitleImportPreflightView(preflight: preflight, startAction: workflow.startResolution)
                    }
                case .resolving:
                    TitleImportProgressView(
                        processedCount: workflow.processedCount,
                        totalCount: workflow.totalCount
                    )
                case .review:
                    TitleImportReviewView(workflow: workflow)
                case .confirmation:
                    TitleImportConfirmationView(workflow: workflow)
                case .importing:
                    TitleImportFinalProgressView(
                        processedCount: workflow.finalImportProcessedCount,
                        totalCount: workflow.finalImportTotalCount
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
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(Strings.Generic.dismissViewDone, role: .legacyClose, action: dismiss.callAsFunction)
                        }
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showCancelButton {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(Strings.Generic.alertButtonCancel, role: .cancel) {
                            if workflow.stage == .importing, workflow.isPerformingWork {
                                isShowingStopConfirmation = true
                            } else {
                                requestDismissal()
                            }
                        }
                        .titleImportDismissalConfirmationDialog(fallbackIsPresented: $isShowingDismissalConfirmation)
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
                    }
                }
            }
        }
        .task { await workflow.loadFile() }
        .interactiveDismissDisabled()
    }

    private var showCancelButton: Bool {
        switch workflow.stage {
        case .loading, .preflight, .resolving, .importing:
            return true

        case .review:
            // If there is no selectable item, hide the cancel button
            guard workflow.includedCount == 0 else { return true }
            return workflow.reviewItems.contains(where: { !$0.inclusionLocked || $0.isIncluded })

        case .confirmation:
            // In confirmation, we show a "back to review" button instead
            return false

        case .summary, .failure:
            return false
        }
    }

    /// Requests dismissal immediately or presents the compatibility confirmation dialog when work would be lost.
    private func requestDismissal() {
        if #available(iOS 27.0, *) {
            // Dismiss confirmation is handled by the view modifier
            dismiss()
        } else {
            isShowingDismissalConfirmation = true
        }
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
#Preview("Review") {
    NavigationStack {
        TitleImportFlowView(workflow: TitleImportPreviewData.workflow())
    }
}
#Preview("Confirmation") {
    NavigationStack {
        TitleImportFlowView(workflow: TitleImportPreviewData.workflow(stage: .confirmation))
    }
}
#Preview("Success") {
    NavigationStack {
        TitleImportFlowView(workflow: TitleImportPreviewData.workflow(stage: .summary))
    }
}
#Preview("Failure") {
    NavigationStack {
        TitleImportFlowView(workflow: TitleImportPreviewData.workflow(stage: .failure))
    }
}
#endif
