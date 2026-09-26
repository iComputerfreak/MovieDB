// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

enum TitleImportTitleMatcher {
    enum Equivalence: Equatable {
        case exact
        case edition
        case subtitle
    }

    private static let romanNumbers: [String: String] = [
        "i": "1", "ii": "2", "iii": "3", "iv": "4", "v": "5",
        "vi": "6", "vii": "7", "viii": "8", "ix": "9", "x": "10",
    ]
    private static let editionWords = [
        "edition", "cut", "extended", "unrated", "uncut", "restoration", "restored",
        "theatrical", "director s", "final", "ultimate", "complete", "commemorative", "special",
    ]

    static func normalize(_ value: String) -> String {
        var value = value.lowercased()
        // Add boundaries around superscripts before compatibility mapping merges them into adjacent words.
        let replacements: [Character: String] = [
            "²": " 2", "³": " 3", "⅓": "1 3", "½": "1 2", "&": " and ",
        ]
        value = String(value.flatMap { replacements[$0] ?? String($0) })
        value = value.precomposedStringWithCompatibilityMapping
        value = value.folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: Locale(identifier: "en_US_POSIX")
        )
        // Split punctuation without restricting titles to the Latin alphabet.
        let words = value
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
            .map { romanNumbers[$0] ?? $0 }
        return words.joined(separator: " ")
    }

    static func variants(for title: String) -> [String] {
        var variants = [title.trimmingCharacters(in: .whitespacesAndNewlines)]
        var stripped = variants[0]

        // Peel only trailing parenthesized/bracketed years or known edition labels, one layer at a time.
        while let match = stripped.wholeMatch(of: /(?s)(.*?)\s*[\[(]([^\])]+)[\])]\s*$/) {
            let label = normalize(String(match.output.2))
            let isYear = label.wholeMatch(of: /(?:18|19|20|21)\d{2}/) != nil
            guard isYear || editionWords.contains(where: label.contains) else { break }
            stripped = String(match.output.1).trimmingCharacters(in: .whitespacesAndNewlines)
            if !stripped.isEmpty { variants.append(stripped) }
        }

        // Remove edition text after a title separator while preserving ordinary subtitles.
        // swiftlint:disable:next line_length
        let suffixPattern = /(?i)\s*[-–:]\s*(?:unrated|uncut|extended|special|theatrical|director['’]?s|final|ultimate|complete|commemorative|\d{4}\s+restoration)\b.*$/
        let withoutEdition = stripped.replacing(suffixPattern, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !withoutEdition.isEmpty { variants.append(withoutEdition) }

        if let separator = stripped.firstIndex(where: { $0 == ":" || $0 == "–" }) {
            let base = String(stripped[..<separator]).trimmingCharacters(in: .whitespacesAndNewlines)
            if base.count >= 3 { variants.append(base) }
        }

        var seen: Set<String> = []
        return variants.filter { variant in
            let normalizedVariant = normalize(variant)
            return !normalizedVariant.isEmpty && seen.insert(normalizedVariant).inserted
        }
    }

    static func equivalence(
        between left: String,
        and right: String,
        exactYearMatch: Bool
    ) -> Equivalence? {
        let normalizedLeft = normalize(left)
        let normalizedRight = normalize(right)
        guard normalizedLeft != normalizedRight else { return .exact }

        let leftEditionBase = editionBase(for: left)
        let rightEditionBase = editionBase(for: right)
        if leftEditionBase != nil || rightEditionBase != nil,
           (leftEditionBase ?? normalizedLeft) == (rightEditionBase ?? normalizedRight) {
            return .edition
        }

        guard exactYearMatch else { return nil }
        let leftSubtitleBase = subtitleBase(for: left)
        let rightSubtitleBase = subtitleBase(for: right)
        if leftSubtitleBase != nil || rightSubtitleBase != nil,
           (leftSubtitleBase ?? normalizedLeft) == (rightSubtitleBase ?? normalizedRight) {
            return .subtitle
        }
        return nil
    }

    static func similarity(_ left: String, _ right: String) -> Double {
        let left = normalize(left)
        let right = normalize(right)
        guard !left.isEmpty, !right.isEmpty else { return 0 }
        guard left != right else { return 1 }

        let leftTokens = Set(left.split(separator: " ").map(String.init))
        let rightTokens = Set(right.split(separator: " ").map(String.init))
        let unionCount = leftTokens.union(rightTokens).count
        let tokenScore = unionCount == 0 ? 0 : Double(leftTokens.intersection(rightTokens).count) / Double(unionCount)
        let editScore = 1 - Double(levenshteinDistance(left, right)) / Double(max(left.count, right.count))
        // Either token overlap or edit similarity may capture a valid title variation; the strongest signal wins.
        return max(tokenScore, editScore, (tokenScore + editScore) / 2)
    }

    static func peopleMatch(_ left: String, _ right: String) -> Bool {
        let leftWords = normalize(left).split(separator: " ")
        let rightWords = normalize(right).split(separator: " ")
        guard let leftFirst = leftWords.first, let rightFirst = rightWords.first,
              let leftLast = leftWords.last, let rightLast = rightWords.last else { return false }
        return leftWords == rightWords ||
            (leftWords.joined() == rightWords.joined()) ||
            (leftLast == rightLast && leftFirst.first == rightFirst.first)
    }

    private static func editionBase(for title: String) -> String? {
        var stripped = title.trimmingCharacters(in: .whitespacesAndNewlines)
        var removedLabel = false
        while let match = stripped.wholeMatch(of: /(?s)(.*?)\s*[\[(]([^\])]+)[\])]\s*$/) {
            let label = normalize(String(match.output.2))
            guard editionWords.contains(where: label.contains) else { break }
            stripped = String(match.output.1).trimmingCharacters(in: .whitespacesAndNewlines)
            removedLabel = true
        }
        return removedLabel ? normalize(stripped) : nil
    }

    private static func subtitleBase(for title: String) -> String? {
        guard let separator = title.firstIndex(of: ":") else { return nil }
        let base = String(title[..<separator]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard base.count >= 3 else { return nil }
        return normalize(base)
    }

    private static func levenshteinDistance(_ left: String, _ right: String) -> Int {
        let left = Array(left)
        let right = Array(right)
        // Keep only the previous dynamic-programming row to avoid a full O(m*n) matrix allocation.
        var previous = Array(0...right.count)
        for (leftIndex, leftCharacter) in left.enumerated() {
            var current = [leftIndex + 1]
            current.reserveCapacity(right.count + 1)
            for (rightIndex, rightCharacter) in right.enumerated() {
                current.append(min(
                    min(current[rightIndex] + 1, previous[rightIndex + 1] + 1),
                    previous[rightIndex] + (leftCharacter == rightCharacter ? 0 : 1)
                ))
            }
            previous = current
        }
        return previous[right.count]
    }
}
