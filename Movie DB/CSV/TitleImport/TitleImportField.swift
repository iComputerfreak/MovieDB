// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

enum TitleImportField: String, CaseIterable, Sendable {
    case title
    case year
    case director
    case runtime
    case mediaType

    static func match(for header: String) -> (field: Self, priority: Int)? {
        let header = normalizeHeader(header)
        for field in allCases {
            guard let priority = aliasGroups[field]?.firstIndex(where: { $0.contains(header) }) else { continue }
            return (field, priority)
        }
        return nil
    }

    static func normalizeHeader(_ value: String) -> String {
        let folded = value
            .precomposedStringWithCompatibilityMapping
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
        return folded
            .replacing(/[^\p{L}\p{N}]+/, with: " ")
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
    }

    // Earlier groups are more specific. This makes dedicated year columns win over date-derived hints.
    private static let aliasGroups: [Self: [Set<String>]] = [
        .title: [["title", "name", "movie title", "film", "media title", "titel", "filmtitel", "medientitel"]],
        .year: [
            ["year", "jahr"],
            ["release year", "erscheinungsjahr", "veroffentlichungsjahr"],
            ["release date", "veroffentlichungsdatum"],
            ["date"],
        ],
        .director: [["director", "directors", "artist", "regisseur", "regisseure", "regie", "kunstler"]],
        .runtime: [["runtime", "duration", "length", "total time", "laufzeit", "dauer", "gesamtdauer"]],
        .mediaType: [["type", "media type", "kind", "typ", "medientyp", "art"]],
    ].mapValues { groups in
        groups.map { Set($0.map(normalizeHeader)) }
    }
}
