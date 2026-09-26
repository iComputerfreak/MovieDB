// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

enum TitleImportReviewFilter: String, CaseIterable, Identifiable {
    case all
    case included
    case ambiguous
    case duplicate
    case noMatch
    case failed

    var id: Self { self }

    var label: String {
        switch self {
        case .all: Strings.TitleImport.Filter.all
        case .included: Strings.TitleImport.Filter.included
        case .ambiguous: Strings.TitleImport.Filter.ambiguous
        case .duplicate: Strings.TitleImport.Filter.duplicates
        case .noMatch: Strings.TitleImport.Filter.noMatch
        case .failed: Strings.TitleImport.Filter.failed
        }
    }
}
