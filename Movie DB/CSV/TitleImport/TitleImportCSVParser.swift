// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation
import SwiftCSV

struct TitleImportCSVParser {
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
        var mappedIndices: [TitleImportField: [Int]] = [:]
        for index in csv.header.indices {
            guard let field = TitleImportField.field(for: csv.header[index]) else { continue }
            mappedIndices[field, default: []].append(index)
        }

        let titleIndices = mappedIndices[.title, default: []]
        guard !titleIndices.isEmpty else {
            throw ParserError.missingTitleHeader(csv.header)
        }
        guard titleIndices.count == 1 else {
            throw ParserError.ambiguousTitleHeader(titleIndices.map { csv.header[$0] })
        }

        var selectedIndices: [TitleImportField: Int] = [.title: titleIndices[0]]
        for field in TitleImportField.allCases where field != .title {
            guard let indices = mappedIndices[field], indices.count == 1 else { continue }
            selectedIndices[field] = indices[0]
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
                        .map(Self.parseDirectors) ?? [],
                    runtimeMinutes: value(for: .runtime, in: values, indices: selectedIndices)
                        .flatMap(Self.parseRuntime),
                    mediaType: value(for: .mediaType, in: values, indices: selectedIndices)
                        .flatMap(Self.parseMediaType)
                )
            )
        }

        guard !rows.isEmpty else { throw ParserError.noRows }

        let mappedHeaders = selectedIndices.mapValues { csv.header[$0] }
        let selectedIndexSet = Set(selectedIndices.values)
        let ignoredHeaders = csv.header.enumerated().compactMap { offset, element in
            selectedIndexSet.contains(offset) ? nil : element
        }
        return TitleImportPreflight(
            rows: rows,
            delimiter: guessedDelimiter.rawValue,
            mappedHeaders: mappedHeaders,
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

    static func parseDirectors(_ value: String) -> [String] {
        let normalized = TitleImportField.normalizeHeader(value)
        guard normalized != "unknown", normalized != "unbekannt" else { return [] }
        // Treat localized conjunctions as separators before handling common CSV list delimiters.
        return value
            .replacing(/(?i:\s+(?:and|und)\s+)/, with: ",")
            .split(whereSeparator: { $0 == "," || $0 == ";" || $0 == "&" })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    static func parseRuntime(_ value: String) -> Int? {
        // Strip localized unit suffixes so plain minute values and clock-style values share one parser.
        let cleaned = value
            .lowercased()
            .replacing(/(?i:\s*(?:minutes?|mins?|minuten?)\.?\s*$)/, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
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

    static func parseMediaType(_ value: String) -> MediaType? {
        switch TitleImportField.normalizeHeader(value) {
        case "movie", "film", "kino":
            return .movie
        case "tv", "show", "series", "television", "serie", "fernsehen":
            return .show
        default:
            return nil
        }
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
