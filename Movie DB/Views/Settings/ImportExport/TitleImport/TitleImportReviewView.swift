// Copyright © 2026 Jonas Frey. All rights reserved.

import AppFoundation
import SwiftUI

/// Displays filterable match results and lets the user choose which candidates to import.
struct TitleImportReviewView: View {
    @Bindable var workflow: TitleImportWorkflow
    @Environment(\.dismiss) private var dismiss: DismissAction
    @State private var isShowingDismissalConfirmation = false

    var body: some View {
        let filteredItems = workflow.filteredReviewItems
        List {
            Section {
                Picker(Strings.TitleImport.Review.filter, selection: $workflow.reviewFilter) {
                    ForEach(TitleImportReviewFilter.allCases) { filter in
                        Text(filter.label).tag(filter)
                    }
                }
                LabeledContent(
                    Strings.TitleImport.Review.selected,
                    value: selectionDescription
                )
            }

            Section {
                ForEach(filteredItems) { item in
                    TitleImportReviewRow(
                        item: item,
                        setIncluded: { workflow.setIncluded($0, itemID: item.id) }
                    )
                    .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in 0 })
                }
            } header: {
                Text(Strings.TitleImport.Review.results)
            }
        }
        .searchable(text: $workflow.reviewSearchText, prompt: Strings.TitleImport.Review.searchPrompt)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if
                    workflow.includedCount == 0,
                    workflow.reviewItems.allSatisfy({ $0.inclusionLocked && !$0.isIncluded })
                {
                    Button(
                        Strings.Generic.dismissViewDone,
                        role: .legacyConfirm,
                        action: { dismiss() }
                    )
                } else {
                    Button(
                        Strings.TitleImport.Review.continueButton,
                        role: .legacyConfirm,
                        action: workflow.prepareForImport
                    )
                    .disabled(workflow.includedCount == 0)
                    .titleImportDismissalConfirmationDialog(
                        fallbackIsPresented: $isShowingDismissalConfirmation
                    )
                }
            }
        }
    }

    /// Requests dismissal immediately or presents the compatibility confirmation dialog when review state exists.
    private func requestDismissal() {
        if #available(iOS 27.0, *) {
            // Dismiss confirmation is handled by the view modifier
            dismiss()
        } else {
            isShowingDismissalConfirmation = true
        }
    }

    private var selectionDescription: String {
        if let limit = workflow.freeSelectionLimit {
            return Strings.TitleImport.Review.selectedWithLimit(workflow.includedCount, workflow.totalCount, limit)
        }
        return Strings.TitleImport.Review.selectedCount(workflow.includedCount, workflow.totalCount)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        TitleImportReviewView(workflow: TitleImportPreviewData.workflow())
            .navigationTitle(Strings.TitleImport.reviewTitle)
    }
}
#endif
