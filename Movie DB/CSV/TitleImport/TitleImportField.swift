// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

enum TitleImportField: String, CaseIterable, Sendable {
    case title
    case year
    case director
    case runtime
    case mediaType

    static func match(for header: String, locale: Locale = .current) -> (field: Self, priority: Int)? {
        let header = normalizeHeader(header)
        let aliasGroups = aliasGroups(locale: locale)
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

    private static func aliasGroups(locale: Locale) -> [Self: [Set<String>]] {
        // Earlier groups are more specific. This makes dedicated year columns win over date-derived hints.
        [
            .title: [aliases(locale: locale, from: Strings.TitleImport.ParserVocabulary.titleHeaders)],
            .year: [
                aliases(locale: locale, from: Strings.TitleImport.ParserVocabulary.exactYearHeaders),
                aliases(locale: locale, from: Strings.TitleImport.ParserVocabulary.releaseYearHeaders),
                aliases(locale: locale, from: Strings.TitleImport.ParserVocabulary.releaseDateHeaders),
                aliases(locale: locale, from: Strings.TitleImport.ParserVocabulary.dateHeaders),
            ],
            .director: [aliases(locale: locale, from: Strings.TitleImport.ParserVocabulary.directorHeaders)],
            .runtime: [aliases(locale: locale, from: Strings.TitleImport.ParserVocabulary.runtimeHeaders)],
            .mediaType: [aliases(locale: locale, from: Strings.TitleImport.ParserVocabulary.mediaTypeHeaders)],
        ]
    }

    private static func aliases(
        locale: Locale,
        from localizedTerms: (Locale) -> [String]
    ) -> Set<String> {
        // English remains available for common export formats regardless of the app's active localization.
        let terms = localizedTerms(Locale(identifier: "en")) + localizedTerms(locale)
        return Set(terms.map(normalizeHeader))
    }
}
