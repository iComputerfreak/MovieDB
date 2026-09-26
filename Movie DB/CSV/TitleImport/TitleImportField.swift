// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

enum TitleImportField: String, CaseIterable, Sendable {
    case title
    case year
    case director
    case runtime
    case mediaType

    static func field(for header: String) -> Self? {
        let header = normalizeHeader(header)
        return allCases.first { aliases[$0, default: []].contains(header) }
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

    private static let aliases: [Self: Set<String>] = [
        .title: ["title", "name", "movie title", "film", "media title", "titel", "filmtitel", "medientitel"],
        .year: [
            "year", "release year", "release date", "date", "jahr", "erscheinungsjahr",
            "veroffentlichungsjahr", "veroffentlichungsdatum",
        ],
        .director: ["director", "directors", "artist", "regisseur", "regisseure", "regie", "kunstler"],
        .runtime: ["runtime", "duration", "length", "total time", "laufzeit", "dauer", "gesamtdauer"],
        .mediaType: ["type", "media type", "kind", "typ", "medientyp", "art"],
    ].mapValues { Set($0.map(normalizeHeader)) }
}
