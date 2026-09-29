// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Creates a complete, spreadsheet-safe CSV audit report for a title import.
enum TitleImportReportExporter {
    private static let headers = [
        "source_row",
        "source_title",
        "source_year",
        "source_directors",
        "source_runtime",
        "source_media_type",
        "confidence_score",
        "runner_up_score",
        "score_margin",
        "pre_import_status",
        "decision",
        "final_outcome",
        "reason",
        "matched_title",
        "matched_original_title",
        "matched_year",
        "matched_media_type",
        "tmdb_id",
        "duplicate_kind",
        "duplicate_source_row",
        "title_match",
        "alternative_title_match",
        "year_match",
        "director_match",
        "runtime_match",
        "media_type_match",
    ]

    /// Creates report data for every nonempty source row, including rows skipped before matching.
    /// - Parameters:
    ///   - preflight: Parsed source rows and final field mappings.
    ///   - reviewItems: Match-review state containing the user's final inclusion decisions.
    ///   - result: Identity-level outcomes from the completed import.
    /// - Returns: A semicolon-separated UTF-8 CSV document.
    static func createData(
        preflight: TitleImportPreflight,
        reviewItems: [TitleImportReviewItem],
        result: TitleImportFinalResult
    ) -> Data {
        let reviewItemsByID = Dictionary(uniqueKeysWithValues: reviewItems.map { ($0.id, $0) })
        let mappedIndices = Dictionary(
            uniqueKeysWithValues: preflight.headerMappings.compactMap { field, header in
                preflight.allHeaders.firstIndex(of: header).map { (field, $0) }
            }
        )
        let importedIdentities = Set(result.importedIdentities)
        let duplicateIdentities = Set(result.duplicateIdentities)
        let failedIdentities = Set(result.failedIdentities)
        let remainingIdentities = Set(result.remainingIdentities)
        var lines = [headers.joined(separator: String(CSVHelper.delimiter))]

        for rawRow in preflight.rawRows {
            let item = reviewItemsByID[rawRow.rowNumber]
            let candidate = item?.candidate
            let duplicateDetails = duplicateDetails(for: item?.duplicateKind)
            let values = [
                rawRow.rowNumber.description,
                sourceValue(for: .title, in: rawRow, mappedIndices: mappedIndices),
                sourceValue(for: .year, in: rawRow, mappedIndices: mappedIndices),
                sourceValue(for: .director, in: rawRow, mappedIndices: mappedIndices),
                sourceValue(for: .runtime, in: rawRow, mappedIndices: mappedIndices),
                sourceValue(for: .mediaType, in: rawRow, mappedIndices: mappedIndices),
                formatted(item?.score),
                formatted(item?.runnerUpScore),
                formatted(item?.scoreMargin),
                item?.status.rawValue ?? "invalid",
                item?.isIncluded == true ? "include" : "exclude",
                finalOutcome(
                    for: item,
                    importedIdentities: importedIdentities,
                    duplicateIdentities: duplicateIdentities,
                    failedIdentities: failedIdentities,
                    remainingIdentities: remainingIdentities
                ),
                item?.reason ?? Strings.TitleImport.Summary.invalidRowReason,
                candidate?.title ?? "",
                candidate?.originalTitle ?? "",
                candidate?.year?.description ?? "",
                candidate?.identity.type.rawValue ?? "",
                candidate?.identity.tmdbID.description ?? "",
                duplicateDetails.kind,
                duplicateDetails.sourceRow,
                boolean(item?.evidence.titleMatch),
                boolean(item?.evidence.alternativeTitleMatch),
                boolean(item?.evidence.yearMatch),
                boolean(item?.evidence.directorMatch),
                boolean(item?.evidence.runtimeMatch),
                boolean(item?.evidence.mediaTypeMatch),
            ]
            lines.append(values.map(escaped).joined(separator: String(CSVHelper.delimiter)))
        }

        return Data(lines.joined(separator: String(CSVHelper.lineSeparator)).utf8)
    }

    /// Reads one mapped source value without interpreting or normalizing its contents.
    /// - Parameters:
    ///   - field: Logical field to read.
    ///   - row: Raw source row.
    ///   - mappedIndices: Final source-column index for each logical field.
    /// - Returns: Original source text, or an empty string when unavailable.
    private static func sourceValue(
        for field: TitleImportField,
        in row: TitleImportRawRow,
        mappedIndices: [TitleImportField: Int]
    ) -> String {
        guard let index = mappedIndices[field], row.values.indices.contains(index) else { return "" }
        return row.values[index]
    }

    /// Maps duplicate provenance to stable report values.
    /// - Parameter duplicateKind: Duplicate provenance captured before import.
    /// - Returns: Stable duplicate kind and owning source-row values.
    private static func duplicateDetails(
        for duplicateKind: TitleImportDuplicateKind?
    ) -> (kind: String, sourceRow: String) {
        switch duplicateKind {
        case .existingLibrary:
            ("existing_library", "")
        case let .sourceRow(row):
            ("source_file", row.description)
        case nil:
            ("", "")
        }
    }

    /// Resolves one review row to its terminal import outcome.
    /// - Parameters:
    ///   - item: Review row, or `nil` for a preflight-invalid row.
    ///   - importedIdentities: Identities persisted by final import.
    ///   - duplicateIdentities: Identities rejected as duplicates during final import.
    ///   - failedIdentities: Identities that failed during final import.
    ///   - remainingIdentities: Identities not processed before final import stopped.
    /// - Returns: A stable machine-readable outcome.
    private static func finalOutcome(
        for item: TitleImportReviewItem?,
        importedIdentities: Set<MediaIdentity>,
        duplicateIdentities: Set<MediaIdentity>,
        failedIdentities: Set<MediaIdentity>,
        remainingIdentities: Set<MediaIdentity>
    ) -> String {
        guard let item else { return "not_imported_invalid" }
        switch item.status {
        case .duplicate:
            return switch item.duplicateKind {
            case .existingLibrary: "not_imported_existing_duplicate"
            case .sourceRow: "not_imported_source_duplicate"
            case nil: "not_imported_duplicate"
            }
        case .noMatch:
            return "not_imported_no_match"
        case .failed:
            return "not_imported_matching_failed"
        case .accepted, .ambiguous:
            guard item.isIncluded else { return "not_imported_excluded" }
        }

        guard let identity = item.candidate?.identity else { return "not_imported_unknown" }
        if importedIdentities.contains(identity) { return "imported" }
        if duplicateIdentities.contains(identity) { return "not_imported_duplicate_during_import" }
        if failedIdentities.contains(identity) { return "not_imported_final_failed" }
        if remainingIdentities.contains(identity) { return "not_imported_remaining" }
        return "not_imported_unknown"
    }

    /// Formats a score with locale-independent decimal punctuation.
    /// - Parameter value: Optional score value.
    /// - Returns: Two-decimal score text, or an empty string.
    private static func formatted(_ value: Double?) -> String {
        guard let value else { return "" }
        return String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), value)
    }

    /// Formats an optional evidence flag.
    /// - Parameter value: Optional evidence flag.
    /// - Returns: `true`, `false`, or an empty string when no review row exists.
    private static func boolean(_ value: Bool?) -> String {
        value.map(String.init) ?? ""
    }

    /// Escapes one CSV field and neutralizes spreadsheet formulas in user-controlled text.
    /// - Parameter value: Unescaped field value.
    /// - Returns: Quoted CSV field text.
    private static func escaped(_ value: String) -> String {
        var safeValue = value
        if let first = safeValue.first,
           ["=", "+", "-", "@", "\t", "\r"].contains(first),
           Double(safeValue) == nil {
            safeValue.insert("'", at: safeValue.startIndex)
        }
        return "\"\(safeValue.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}
