// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

/// Summarizes the reviewed selection and asks the user to confirm final import.
struct TitleImportConfirmationView: View {
    let workflow: TitleImportWorkflow

    var body: some View {
        List {
            Section {
                LabeledContent(Strings.TitleImport.Confirmation.selected, value: workflow.includedCount.description)
                LabeledContent(Strings.TitleImport.Confirmation.excluded, value: workflow.excludedCount.description)
                LabeledContent(
                    Strings.TitleImport.Confirmation.ambiguousIncluded,
                    value: workflow.ambiguousIncludedCount.description
                )
            }

            Section {
                LabeledContent(
                    Strings.TitleImport.Confirmation.existingDuplicates,
                    value: workflow.existingDuplicateCount.description
                )
                LabeledContent(
                    Strings.TitleImport.Confirmation.fileDuplicates,
                    value: workflow.fileDuplicateCount.description
                )
                LabeledContent(
                    Strings.TitleImport.Confirmation.noMatch,
                    value: workflow.count(for: .noMatch).description
                )
                LabeledContent(
                    Strings.TitleImport.Confirmation.failed,
                    value: workflow.count(for: .failed).description
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(
                    Strings.TitleImport.Confirmation.back,
                    role: .cancel,
                    action: workflow.returnToReview
                )
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(
                    Strings.TitleImport.Confirmation.importSelected,
                    role: .legacyConfirm,
                    action: workflow.startImport
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        TitleImportConfirmationView(workflow: TitleImportPreviewData.workflow(stage: .confirmation))
            .navigationTitle(Strings.TitleImport.Confirmation.title)
    }
}
#endif
