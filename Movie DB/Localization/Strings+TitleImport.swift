// Copyright © 2026 Jonas Frey. All rights reserved.

extension Strings {
    enum TitleImport {
        static let settingsAction = String(
            localized: "titleImport.settingsAction",
            defaultValue: "Import CSV by Title",
            comment: "Settings action"
        )
        static let title = String(
            localized: "titleImport.title",
            defaultValue: "CSV Import",
            comment: "Import flow title"
        )
        static let reviewTitle = String(
            localized: "titleImport.review.title",
            defaultValue: "Review Matches",
            comment: "Import review title"
        )
        static let loadingFile = String(
            localized: "titleImport.loadingFile",
            defaultValue: "Reading CSV...",
            comment: "CSV loading progress"
        )

        static func fieldName(_ field: TitleImportField) -> String {
            switch field {
            case .title:
                String(localized: "titleImport.field.title", defaultValue: "Title", comment: "Title CSV field")
            case .year:
                String(localized: "titleImport.field.year", defaultValue: "Year", comment: "Year CSV field")
            case .director:
                String(localized: "titleImport.field.director", defaultValue: "Director", comment: "Director CSV field")
            case .runtime:
                String(localized: "titleImport.field.runtime", defaultValue: "Runtime", comment: "Runtime CSV field")
            case .mediaType:
                String(localized: "titleImport.field.mediaType", defaultValue: "Media Type", comment: "Media type CSV field")
            }
        }

        enum Error {
            static let title = String(
                localized: "titleImport.error.title",
                defaultValue: "Unable to Import CSV",
                comment: "Title import error title"
            )
            static let emptyFile = String(
                localized: "titleImport.error.emptyFile",
                defaultValue: "The selected CSV file is empty.",
                comment: "Empty CSV error"
            )
            static let unsupportedDelimiter = String(
                localized: "titleImport.error.unsupportedDelimiter",
                defaultValue: "Only comma- and semicolon-separated CSV files are supported.",
                comment: "Unsupported CSV delimiter error"
            )
            static func missingTitleHeader(_ headers: String) -> String {
                String(
                    localized: "titleImport.error.missingTitleHeader",
                    defaultValue: "No title column was found. Available headers: \(headers)",
                    comment: "Missing title header error. Argument lists found headers."
                )
            }
            static func ambiguousTitleHeader(_ headers: String) -> String {
                String(
                    localized: "titleImport.error.ambiguousTitleHeader",
                    defaultValue: "Multiple title columns were found: \(headers)",
                    comment: "Ambiguous title header error. Argument lists matching headers."
                )
            }
            static let noRows = String(
                localized: "titleImport.error.noRows",
                defaultValue: "The CSV file contains no usable media rows.",
                comment: "No usable CSV rows error"
            )
        }

        enum Preflight {
            static let fileSection = String(
                localized: "titleImport.preflight.file",
                defaultValue: "File",
                comment: "File summary section"
            )
            static let rows = String(
                localized: "titleImport.preflight.rows",
                defaultValue: "Media Rows",
                comment: "CSV row count label"
            )
            static let delimiter = String(
                localized: "titleImport.preflight.delimiter",
                defaultValue: "Delimiter",
                comment: "CSV delimiter label"
            )
            static let skippedRows = String(
                localized: "titleImport.preflight.skippedRows",
                defaultValue: "Skipped Rows",
                comment: "Skipped malformed rows label"
            )
            static let columnsSection = String(
                localized: "titleImport.preflight.columns",
                defaultValue: "Detected Columns",
                comment: "Detected columns section"
            )
            static let ignoredColumnsSection = String(
                localized: "titleImport.preflight.ignoredColumns",
                defaultValue: "Ignored Columns",
                comment: "Ignored columns section"
            )
            static let start = String(
                localized: "titleImport.preflight.start",
                defaultValue: "Find Matches",
                comment: "Start matching button"
            )
            static let foregroundWarning = String(
                localized: "titleImport.preflight.foregroundWarning",
                defaultValue: "Keep Movie DB open while matches are being found.",
                comment: "Foreground processing warning"
            )
            static let comma = String(
                localized: "titleImport.preflight.comma",
                defaultValue: "Comma",
                comment: "Comma delimiter"
            )
            static let semicolon = String(
                localized: "titleImport.preflight.semicolon",
                defaultValue: "Semicolon",
                comment: "Semicolon delimiter"
            )
        }

        enum Progress {
            static func resolving(_ processed: Int, _ total: Int) -> String {
                String(
                    localized: "titleImport.progress.resolving",
                    defaultValue: "Matched \(processed) of \(total)",
                    comment: "Matching progress. Arguments are processed and total row counts."
                )
            }
        }

        enum Match {
            static let noResults = String(
                localized: "titleImport.match.noResults",
                defaultValue: "No TMDB match found.",
                comment: "No TMDB result"
            )
            static func accepted(_ score: Int) -> String {
                String(
                    localized: "titleImport.match.accepted",
                    defaultValue: "Confident match (score \(score)).",
                    comment: "Accepted match score"
                )
            }
            static func ambiguous(_ score: Int, _ margin: Int) -> String {
                String(
                    localized: "titleImport.match.ambiguous",
                    defaultValue: "Review suggested match (score \(score), lead \(margin)).",
                    comment: "Ambiguous match score and runner-up margin"
                )
            }
            static let existingDuplicate = String(
                localized: "titleImport.match.existingDuplicate",
                defaultValue: "Already in your library.",
                comment: "Match already exists in library"
            )
            static func fileDuplicate(_ row: Int) -> String {
                String(
                    localized: "titleImport.match.fileDuplicate",
                    defaultValue: "Same TMDB media as source row \(row).",
                    comment: "Duplicate source row number"
                )
            }
        }

        enum Filter {
            static let all = String(localized: "titleImport.filter.all", defaultValue: "All", comment: "All results filter")
            static let included = String(
                localized: "titleImport.filter.included",
                defaultValue: "Included",
                comment: "Included results filter"
            )
            static let ambiguous = String(
                localized: "titleImport.filter.ambiguous",
                defaultValue: "Ambiguous",
                comment: "Ambiguous results filter"
            )
            static let duplicates = String(
                localized: "titleImport.filter.duplicates",
                defaultValue: "Duplicates",
                comment: "Duplicate results filter"
            )
            static let noMatch = String(
                localized: "titleImport.filter.noMatch",
                defaultValue: "No Match",
                comment: "No match results filter"
            )
            static let failed = String(
                localized: "titleImport.filter.failed",
                defaultValue: "Failed",
                comment: "Failed results filter"
            )
        }

        enum Review {
            static let filter = String(
                localized: "titleImport.review.filter",
                defaultValue: "Filter",
                comment: "Review filter picker"
            )
            static let selected = String(
                localized: "titleImport.review.selected",
                defaultValue: "Selected",
                comment: "Selected count label"
            )
            static func selectedWithLimit(_ selected: Int, _ limit: Int) -> String {
                String(
                    localized: "titleImport.review.selectedWithLimit",
                    defaultValue: "\(selected) of \(limit)",
                    comment: "Selected count and free-user limit"
                )
            }
            static func results(_ count: Int) -> String {
                String(
                    localized: "titleImport.review.results",
                    defaultValue: "Results (\(count))",
                    comment: "Visible review result count"
                )
            }
            static let searchPrompt = String(
                localized: "titleImport.review.search",
                defaultValue: "Search results",
                comment: "Review search prompt"
            )
            static let include = String(
                localized: "titleImport.review.include",
                defaultValue: "Include",
                comment: "Include match toggle"
            )
        }

        enum Status {
            static let accepted = String(
                localized: "titleImport.status.accepted",
                defaultValue: "Accepted",
                comment: "Accepted match status"
            )
            static let ambiguous = String(
                localized: "titleImport.status.ambiguous",
                defaultValue: "Needs Review",
                comment: "Ambiguous match status"
            )
            static let duplicate = String(
                localized: "titleImport.status.duplicate",
                defaultValue: "Duplicate",
                comment: "Duplicate match status"
            )
            static let noMatch = String(
                localized: "titleImport.status.noMatch",
                defaultValue: "No Match",
                comment: "No match status"
            )
            static let failed = String(
                localized: "titleImport.status.failed",
                defaultValue: "Failed",
                comment: "Failed match status"
            )
        }
    }
}
