// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TitleImportReviewView: View {
    @Bindable var workflow: TitleImportWorkflow

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
                    .listRowSeparatorTint(.white80)
                    .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in 0 })
                }
            } header: {
                Text(Strings.TitleImport.Review.results(filteredItems.count))
            }
        }
        .searchable(text: $workflow.reviewSearchText, prompt: Strings.TitleImport.Review.searchPrompt)
    }

    private var selectionDescription: String {
        if let limit = workflow.freeSelectionLimit {
            return Strings.TitleImport.Review.selectedWithLimit(workflow.includedCount, limit)
        }
        return workflow.includedCount.description
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
