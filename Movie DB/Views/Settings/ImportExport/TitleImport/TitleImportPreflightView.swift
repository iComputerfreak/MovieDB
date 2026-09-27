// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TitleImportPreflightView: View {
    @Binding var preflight: TitleImportPreflight
    let startAction: () -> Void

    var body: some View {
        Form {
            Section(Strings.TitleImport.Preflight.fileSection) {
                LabeledContent(Strings.TitleImport.Preflight.rows, value: preflight.rows.count.description)
                LabeledContent(Strings.TitleImport.Preflight.delimiter, value: delimiterName)
                if preflight.malformedRowCount > 0 {
                    LabeledContent(
                        Strings.TitleImport.Preflight.skippedRows,
                        value: preflight.malformedRowCount.description
                    )
                    .foregroundStyle(.orange)
                }
            }

            Section(Strings.TitleImport.Preflight.columnsSection) {
                ForEach(TitleImportField.allCases, id: \.self) { field in
                    Picker(Strings.TitleImport.fieldName(field), selection: $preflight.headerMappings[field]) {
                        Text(Strings.TitleImport.noColumn)
                            .tag(nil as String?)

                        ForEach(preflight.allHeaders, id: \.self) { header in
                            Text(header)
                                .tag(header as String?)
                        }
                    }
                }
            }

            if !preflight.ignoredHeaders.isEmpty {
                Section {
                    Text(preflight.ignoredHeaders.joined(separator: ", "))
                        .foregroundStyle(.secondary)
                } header: {
                    Text(Strings.TitleImport.Preflight.ignoredColumnsSection)
                } footer: {
                    Text(Strings.TitleImport.Preflight.foregroundWarning)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: startAction) {
                    Text(Strings.TitleImport.Preflight.start)
                }
            }
        }
    }

    private var delimiterName: String {
        switch preflight.delimiter {
        case ",": Strings.TitleImport.Preflight.comma
        case ";": Strings.TitleImport.Preflight.semicolon
        default: String(preflight.delimiter)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var preflight = TitleImportPreviewData.preflight

    NavigationStack {
        TitleImportPreflightView(preflight: $preflight, startAction: {})
            .navigationTitle(Strings.TitleImport.title)
    }
}
#endif
