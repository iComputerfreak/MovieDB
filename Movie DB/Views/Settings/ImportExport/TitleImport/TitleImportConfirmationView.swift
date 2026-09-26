// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

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

            Section {
                LabeledContent(
                    Strings.TitleImport.Confirmation.estimatedTime,
                    value: Strings.TitleImport.Confirmation.minimumSeconds(workflow.estimatedImportSeconds)
                )
            }

            Section {
                Button(Strings.TitleImport.Confirmation.importSelected, action: workflow.startImport)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .listRowBackground(Color.clear)
                Button(Strings.TitleImport.Confirmation.back, action: workflow.returnToReview)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
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
