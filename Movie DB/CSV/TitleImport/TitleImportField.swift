// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Defines the logical CSV columns understood by title-based import.
enum TitleImportField: String, CaseIterable, Sendable {
    case title
    case year
    case director
    case runtime
    case mediaType

    /// Matches a CSV header against ranked English and localized aliases.
    /// - Parameters:
    ///   - header: The raw CSV header to classify.
    ///   - locale: The locale whose header aliases should supplement English aliases.
    /// - Returns: The matching field and alias priority, or `nil` when no alias matches.
    static func match(for header: String, locale: Locale = .current) -> (field: Self, priority: Int)? {
        let header = normalizeHeader(header)
        let aliasGroups = aliasGroups(locale: locale)
        for field in allCases {
            guard let priority = aliasGroups[field]?.firstIndex(where: { $0.contains(header) }) else { continue }
            return (field, priority)
        }
        return nil
    }

    /// Normalizes a header or vocabulary term for punctuation-, case-, and diacritic-insensitive comparison.
    /// - Parameter value: The text to normalize.
    /// - Returns: A space-separated sequence of Unicode letters and numbers.
    static func normalizeHeader(_ value: String) -> String {
        let folded = value
            .precomposedStringWithCompatibilityMapping
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
        return folded
            .replacing(/[^\p{L}\p{N}]+/, with: " ")
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
    }

    /// Builds ranked normalized alias groups for every logical field.
    /// - Parameter locale: The locale whose aliases should supplement English aliases.
    /// - Returns: Alias sets ordered from most specific to least specific for each field.
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

    /// Combines and normalizes English aliases with aliases from one locale.
    /// - Parameters:
    ///   - locale: The locale whose aliases should be included.
    ///   - localizedTerms: A localized alias provider for one field or priority group.
    /// - Returns: The deduplicated normalized aliases.
    private static func aliases(
        locale: Locale,
        from localizedTerms: (Locale) -> [String]
    ) -> Set<String> {
        // English remains available for common export formats regardless of the app's active localization.
        let terms = localizedTerms(Locale(identifier: "en")) + localizedTerms(locale)
        return Set(terms.map(normalizeHeader))
    }
}
