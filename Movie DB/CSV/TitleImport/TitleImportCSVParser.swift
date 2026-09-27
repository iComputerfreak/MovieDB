// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation
import SwiftCSV

struct TitleImportCSVParser {
    private let locale: Locale

    init(locale: Locale = .current) {
        self.locale = locale
    }

    enum ParserError: LocalizedError {
        case emptyFile
        case unsupportedDelimiter
        case missingTitleHeader([String])
        case ambiguousTitleHeader([String])
        case noRows

        var errorDescription: String? {
            switch self {
            case .emptyFile:
                return Strings.TitleImport.Error.emptyFile
            case .unsupportedDelimiter:
                return Strings.TitleImport.Error.unsupportedDelimiter
            case let .missingTitleHeader(headers):
                return Strings.TitleImport.Error.missingTitleHeader(headers.joined(separator: ", "))
            case let .ambiguousTitleHeader(headers):
                return Strings.TitleImport.Error.ambiguousTitleHeader(headers.joined(separator: ", "))
            case .noRows:
                return Strings.TitleImport.Error.noRows
            }
        }
    }

    // swiftlint:disable:next function_body_length
    func parse(string: String) throws -> TitleImportPreflight {
        guard !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ParserError.emptyFile
        }

        let guessedDelimiter = CSVDelimiter.guessed(string: string)
        guard guessedDelimiter.rawValue == "," || guessedDelimiter.rawValue == ";" else {
            throw ParserError.unsupportedDelimiter
        }

        let csv = try CSV<Enumerated>(string: string, delimiter: guessedDelimiter, loadColumns: false)
        var mappedIndices: [TitleImportField: [(index: Int, priority: Int)]] = [:]
        for index in csv.header.indices {
            guard let match = TitleImportField.match(for: csv.header[index], locale: locale) else { continue }
            mappedIndices[match.field, default: []].append((index, match.priority))
        }

        let titleIndices = mappedIndices[.title, default: []]
        guard !titleIndices.isEmpty else {
            throw ParserError.missingTitleHeader(csv.header)
        }
        guard titleIndices.count == 1 else {
            throw ParserError.ambiguousTitleHeader(titleIndices.map { csv.header[$0.index] })
        }

        var selectedIndices: [TitleImportField: Int] = [.title: titleIndices[0].index]
        for field in TitleImportField.allCases where field != .title {
            guard let matches = mappedIndices[field], let bestPriority = matches.map(\.priority).min() else { continue }
            let preferredMatches = matches.filter { $0.priority == bestPriority }
            guard preferredMatches.count == 1 else { continue }
            selectedIndices[field] = preferredMatches[0].index
        }

        var malformedRowCount = 0
        var rows: [TitleImportSourceRow] = []
        rows.reserveCapacity(csv.rows.count)
        for (offset, values) in csv.rows.enumerated() {
            if values.allSatisfy({ $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                continue
            }
            guard
                let rawTitle = value(for: .title, in: values, indices: selectedIndices),
                !rawTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                malformedRowCount += 1
                continue
            }

            let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let explicitYear = value(for: .year, in: values, indices: selectedIndices).flatMap(Self.parseYear)
            rows.append(
                TitleImportSourceRow(
                    id: offset + 2,
                    title: title,
                    year: explicitYear ?? Self.yearFromTitle(title),
                    directors: value(for: .director, in: values, indices: selectedIndices)
                        .map { Self.parseDirectors($0, locale: locale) } ?? [],
                    runtimeMinutes: value(for: .runtime, in: values, indices: selectedIndices)
                        .flatMap { Self.parseRuntime($0, locale: locale) },
                    mediaType: value(for: .mediaType, in: values, indices: selectedIndices)
                        .flatMap { Self.parseMediaType($0, locale: locale) }
                )
            )
        }

        guard !rows.isEmpty else { throw ParserError.noRows }

        let mappedHeaders: [TitleImportField: String?] = Dictionary(
            uniqueKeysWithValues: TitleImportField.allCases.map { field in
                if let selectedIndex = selectedIndices[field] {
                    return (field, csv.header[selectedIndex])
                } else {
                    return (field, nil)
                }
            }
        )
        let selectedIndexSet = Set(selectedIndices.values)
        let ignoredHeaders = csv.header.enumerated().compactMap { offset, element in
            selectedIndexSet.contains(offset) ? nil : element
        }
        return TitleImportPreflight(
            rows: rows,
            delimiter: guessedDelimiter.rawValue,
            allHeaders: csv.header,
            headerMappings: mappedHeaders,
            ignoredHeaders: ignoredHeaders,
            malformedRowCount: malformedRowCount
        )
    }

    private func value(
        for field: TitleImportField,
        in row: [String],
        indices: [TitleImportField: Int]
    ) -> String? {
        guard let index = indices[field], row.indices.contains(index) else { return nil }
        let value = row[index].trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}

// MARK: - Value Parsing
extension TitleImportCSVParser {
    static func parseYear(_ value: String) -> Int? {
        // Constrain matching to plausible movie/TV years instead of accepting any four-digit metadata value.
        guard let match = value.firstMatch(of: /(?:18|19|20|21)\d{2}/) else { return nil }
        return Int(match.output)
    }

    static func yearFromTitle(_ title: String) -> Int? {
        // A year is a title hint only when it is the final parenthesized component.
        guard let match = title.firstMatch(of: /\(((?:18|19|20|21)\d{2})\)\s*$/) else { return nil }
        return Int(match.output.1)
    }

    static func parseDirectors(_ value: String, locale: Locale = .current) -> [String] {
        let normalized = TitleImportField.normalizeHeader(value)
        let unknownValues = vocabulary(locale: locale, from: Strings.TitleImport.ParserVocabulary.unknownDirectors)
            .map(TitleImportField.normalizeHeader)
        guard !unknownValues.contains(normalized) else { return [] }
        // Treat localized conjunctions as separators before handling common CSV list delimiters.
        let separated = vocabulary(locale: locale, from: Strings.TitleImport.ParserVocabulary.directorConjunctions)
            .reduce(value) { value, conjunction in
                value.replacingOccurrences(
                    of: " \(conjunction) ",
                    with: ",",
                    options: [.caseInsensitive, .diacriticInsensitive]
                )
            }
        return separated
            .split(whereSeparator: { $0 == "," || $0 == ";" || $0 == "&" })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    static func parseRuntime(_ value: String, locale: Locale = .current) -> Int? {
        // Strip localized unit suffixes so plain minute values and clock-style values share one parser.
        var cleaned = value
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasSuffix(".") {
            cleaned.removeLast()
            cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let runtimeUnits = vocabulary(locale: locale, from: Strings.TitleImport.ParserVocabulary.runtimeUnits)
            .sorted { $0.count > $1.count }
        for unit in runtimeUnits {
            guard let range = cleaned.range(
                of: unit,
                options: [.caseInsensitive, .diacriticInsensitive, .backwards, .anchored]
            ) else { continue }
            cleaned = cleaned[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
            break
        }
        if let minutes = Int(cleaned), minutes > 0 {
            return minutes
        }

        let parts = cleaned.split(separator: ":", omittingEmptySubsequences: false)
        do {
            // A decimal final component denotes seconds; two integer components denote hours and minutes.
            switch parts.count {
            case 2 where parts[1].contains("."):
                let minutes = try requiredInt(parts[0])
                let seconds = try requiredDouble(parts[1])
                return Int((Double(minutes) + seconds / 60).rounded())
            case 2:
                let hours = try requiredInt(parts[0])
                let minutes = try requiredInt(parts[1])
                return hours * 60 + minutes
            case 3:
                let hours = try requiredInt(parts[0])
                let minutes = try requiredInt(parts[1])
                let seconds = try requiredDouble(parts[2])
                return Int((Double(hours * 60 + minutes) + seconds / 60).rounded())
            default:
                return nil
            }
        } catch {
            return nil
        }
    }

    static func parseMediaType(_ value: String, locale: Locale = .current) -> MediaType? {
        let normalized = TitleImportField.normalizeHeader(value)
        let movies = vocabulary(locale: locale, from: Strings.TitleImport.ParserVocabulary.movieValues)
            .map(TitleImportField.normalizeHeader)
        let shows = vocabulary(locale: locale, from: Strings.TitleImport.ParserVocabulary.showValues)
            .map(TitleImportField.normalizeHeader)
        switch normalized {
        case _ where movies.contains(normalized):
            return .movie
        case _ where shows.contains(normalized):
            return .show
        default:
            return nil
        }
    }

    private static func vocabulary(
        locale: Locale,
        from localizedTerms: (Locale) -> [String]
    ) -> Set<String> {
        Set(localizedTerms(Locale(identifier: "en")) + localizedTerms(locale))
    }

    private static func requiredInt(_ value: Substring) throws -> Int {
        guard let result = Int(value) else { throw ParseError.invalidNumber }
        return result
    }

    private static func requiredDouble(_ value: Substring) throws -> Double {
        guard let result = Double(value) else { throw ParseError.invalidNumber }
        return result
    }

    private enum ParseError: Error {
        case invalidNumber
    }
}
