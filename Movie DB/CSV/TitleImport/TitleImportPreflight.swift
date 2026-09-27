// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Contains raw rows and editable header-mapping metadata shown before resolution begins.
struct TitleImportPreflight: Sendable {
    let rawRows: [TitleImportRawRow]
    let delimiter: Character
    let allHeaders: [String]
    var headerMappings: [TitleImportField: String]

    var hasTitleMapping: Bool { titleColumnIndex != nil }
    var usableRowCount: Int {
        guard let titleColumnIndex else { return 0 }
        return rawRows.count { row in
            row.values.indices.contains(titleColumnIndex) &&
                !row.values[titleColumnIndex].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    var displayedRowCount: Int { hasTitleMapping ? usableRowCount : rawRows.count }
    var malformedRowCount: Int { hasTitleMapping ? rawRows.count - usableRowCount : 0 }
    var canStartResolution: Bool { hasTitleMapping && usableRowCount > 0 }
    var ignoredHeaders: [String] {
        let selectedHeaders = Set(headerMappings.values)
        return allHeaders.filter { !selectedHeaders.contains($0) }
    }

    private var titleColumnIndex: Int? {
        guard let titleHeader = headerMappings[.title] else { return nil }
        return allHeaders.firstIndex(of: titleHeader)
    }
}
