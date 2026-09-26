// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TitleImportPreflightView: View {
    let preflight: TitleImportPreflight
    let startAction: () -> Void

    var body: some View {
        List {
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
                    if let header = preflight.mappedHeaders[field] {
                        LabeledContent(Strings.TitleImport.fieldName(field), value: header)
                    }
                }
            }

            if !preflight.ignoredHeaders.isEmpty {
                Section(Strings.TitleImport.Preflight.ignoredColumnsSection) {
                    Text(preflight.ignoredHeaders.joined(separator: ", "))
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button(action: startAction) {
                    Text(Strings.TitleImport.Preflight.start)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .listRowBackground(Color.clear)
            } footer: {
                Text(Strings.TitleImport.Preflight.foregroundWarning)
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
