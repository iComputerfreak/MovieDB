// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

extension Strings {
    /// Provides localized user-facing text and parser vocabulary for title-based CSV import.
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
        static let noColumn = String(
            localized: "titleImport.noColumn",
            defaultValue: "— No column —",
            comment: "Picker value for mapping a field to no column."
        )

        /// Returns the localized display name for a logical import field.
        /// - Parameter field: The field whose name should be displayed.
        /// - Returns: The localized field name.
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

        /// Loads locale-specific parser terms from pipe-separated String Catalog values.
        enum ParserVocabulary {
            /// Loads localized title-header aliases.
            /// - Parameter locale: The localization to load.
            /// - Returns: Title-header aliases for the locale.
            static func titleHeaders(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.header.title",
                        defaultValue: "title|name|movie title|film|media title",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated CSV title header aliases. Keep the pipe separators."
                    )
                )
            }

            /// Loads localized exact-year header aliases.
            /// - Parameter locale: The localization to load.
            /// - Returns: Exact-year header aliases for the locale.
            static func exactYearHeaders(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.header.year.exact",
                        defaultValue: "year",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated exact year CSV header aliases. Keep the pipe separators."
                    )
                )
            }

            /// Loads localized release-year header aliases.
            /// - Parameter locale: The localization to load.
            /// - Returns: Release-year header aliases for the locale.
            static func releaseYearHeaders(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.header.year.releaseYear",
                        defaultValue: "release year",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated release-year CSV header aliases. Keep the pipe separators."
                    )
                )
            }

            /// Loads localized release-date header aliases.
            /// - Parameter locale: The localization to load.
            /// - Returns: Release-date header aliases for the locale.
            static func releaseDateHeaders(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.header.year.releaseDate",
                        defaultValue: "release date",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated release-date CSV header aliases. Keep the pipe separators."
                    )
                )
            }

            /// Loads localized generic-date header aliases.
            /// - Parameter locale: The localization to load.
            /// - Returns: Generic-date header aliases for the locale.
            static func dateHeaders(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.header.year.date",
                        defaultValue: "date",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated generic date CSV header aliases. Keep the pipe separators."
                    )
                )
            }

            /// Loads localized director-header aliases.
            /// - Parameter locale: The localization to load.
            /// - Returns: Director-header aliases for the locale.
            static func directorHeaders(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.header.director",
                        defaultValue: "director|directors|artist",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated CSV director header aliases. Keep the pipe separators."
                    )
                )
            }

            /// Loads localized runtime-header aliases.
            /// - Parameter locale: The localization to load.
            /// - Returns: Runtime-header aliases for the locale.
            static func runtimeHeaders(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.header.runtime",
                        defaultValue: "runtime|duration|length|total time",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated CSV runtime header aliases. Keep the pipe separators."
                    )
                )
            }

            /// Loads localized media-type header aliases.
            /// - Parameter locale: The localization to load.
            /// - Returns: Media-type header aliases for the locale.
            static func mediaTypeHeaders(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.header.mediaType",
                        defaultValue: "type|media type|kind",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated CSV media-type header aliases. Keep the pipe separators."
                    )
                )
            }

            /// Loads localized values representing an unknown director.
            /// - Parameter locale: The localization to load.
            /// - Returns: Unknown-director values for the locale.
            static func unknownDirectors(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.director.unknown",
                        defaultValue: "unknown",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated values meaning an unknown director. Keep the pipe separators."
                    )
                )
            }

            /// Loads localized conjunctions that separate director names.
            /// - Parameter locale: The localization to load.
            /// - Returns: Director conjunctions for the locale.
            static func directorConjunctions(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.director.conjunctions",
                        defaultValue: "and",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated conjunctions joining director names. Keep the pipe separators."
                    )
                )
            }

            /// Loads localized minute-unit suffixes.
            /// - Parameter locale: The localization to load.
            /// - Returns: Runtime unit suffixes for the locale.
            static func runtimeUnits(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.runtime.units",
                        defaultValue: "minute|minutes|min|mins",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated minute unit suffixes. Keep the pipe separators."
                    )
                )
            }

            /// Loads localized values representing movies.
            /// - Parameter locale: The localization to load.
            /// - Returns: Movie values for the locale.
            static func movieValues(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.mediaType.movie",
                        defaultValue: "movie|film",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated CSV values meaning movie. Keep the pipe separators."
                    )
                )
            }

            /// Loads localized values representing TV shows.
            /// - Parameter locale: The localization to load.
            /// - Returns: TV-show values for the locale.
            static func showValues(locale: Locale) -> [String] {
                terms(
                    String(
                        localized: "titleImport.parser.mediaType.show",
                        defaultValue: "tv|show|series|television",
                        bundle: localizedBundle(for: locale),
                        locale: locale,
                        comment: "Pipe-separated CSV values meaning TV show. Keep the pipe separators."
                    )
                )
            }

            /// Splits a pipe-separated localized vocabulary value into trimmed terms.
            /// - Parameter value: The localized pipe-separated value.
            /// - Returns: Nonempty terms in catalog order.
            private static func terms(_ value: String) -> [String] {
                value.split(separator: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            }

            /// Resolves the app localization bundle that best matches a locale.
            /// - Parameter locale: The requested locale.
            /// - Returns: The matching localization bundle, or the main bundle when no match can be loaded.
            private static func localizedBundle(for locale: Locale) -> Bundle {
                let localization = Bundle.preferredLocalizations(
                    from: Bundle.main.localizations,
                    forPreferences: [locale.identifier]
                ).first
                guard let localization,
                      let path = Bundle.main.path(forResource: localization, ofType: "lproj"),
                      let bundle = Bundle(path: path) else {
                    return .main
                }
                return bundle
            }
        }

        /// Provides localized errors for CSV parsing and workflow failures.
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
            /// Formats an error listing headers when no title column can be recognized.
            /// - Parameter headers: The available headers formatted for display.
            /// - Returns: The localized missing-title-column error.
            static func missingTitleHeader(_ headers: String) -> String {
                String(
                    localized: "titleImport.error.missingTitleHeader",
                    defaultValue: "No title column was found. Available headers: \(headers)",
                    comment: "Missing title header error. Argument lists found headers."
                )
            }
            /// Formats an error listing multiple recognized title columns.
            /// - Parameter headers: The conflicting headers formatted for display.
            /// - Returns: The localized ambiguous-title-column error.
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

        /// Provides localized text for parsed-file preflight and header mapping.
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

        /// Provides localized text for candidate-resolution progress.
        enum Progress {
            /// Formats current title-resolution progress.
            /// - Parameters:
            ///   - processed: The number of completed source rows.
            ///   - total: The total number of source rows.
            /// - Returns: The localized progress description.
            static func resolving(_ processed: Int, _ total: Int) -> String {
                String(
                    localized: "titleImport.progress.resolving",
                    defaultValue: "Matched \(processed) of \(total)",
                    comment: "Matching progress. Arguments are processed and total row counts."
                )
            }
        }

        /// Provides localized explanations for match and duplicate outcomes.
        enum Match {
            static let noResults = String(
                localized: "titleImport.match.noResults",
                defaultValue: "No TMDB match found.",
                comment: "No TMDB result"
            )
            static let accepted = String(
                localized: "titleImport.match.accepted",
                defaultValue: "Confident match.",
                comment: "Accepted match score"
            )
            static let ambiguous = String(
                localized: "titleImport.match.ambiguous",
                defaultValue: "Review suggested match.",
                comment: "Ambiguous match score and runner-up margin"
            )
            static let existingDuplicate = String(
                localized: "titleImport.match.existingDuplicate",
                defaultValue: "Already in your library.",
                comment: "Match already exists in library"
            )
            /// Formats the source-row owner of a repeated TMDB identity.
            /// - Parameter row: The earlier source row that owns the identity.
            /// - Returns: The localized file-duplicate explanation.
            static func fileDuplicate(_ row: Int) -> String {
                String(
                    localized: "titleImport.match.fileDuplicate",
                    defaultValue: "Same TMDB media as source row \(row).",
                    comment: "Duplicate source row number"
                )
            }
        }

        /// Provides localized labels for review filters.
        enum Filter {
            static let all = String(localized: "titleImport.filter.all", defaultValue: "All", comment: "All results filter")
            static let included = String(
                localized: "titleImport.filter.included",
                defaultValue: "Included",
                comment: "Included results filter"
            )
            static let notIncluded = String(
                localized: "titleImport.filter.notIncluded",
                defaultValue: "Not Included",
                comment: "Not included results filter"
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

        /// Provides localized text for selecting and filtering review results.
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
            /// Formats selected and total review counts.
            /// - Parameters:
            ///   - selected: The number of included review items.
            ///   - total: The total number of review items.
            /// - Returns: The localized selection count.
            static func selectedCount(_ selected: Int, _ total: Int) -> String {
                String(
                    localized: "titleImport.review.selectedCount",
                    defaultValue: "\(selected) of \(total)",
                    comment: "Selected count and total count"
                )
            }
            /// Formats selection counts together with the active free-user limit.
            /// - Parameters:
            ///   - selected: The number of included review items.
            ///   - total: The total number of review items.
            ///   - limit: The maximum number of items the user may select.
            /// - Returns: The localized selection and limit description.
            static func selectedWithLimit(_ selected: Int, _ total: Int, _ limit: Int) -> String {
                String(
                    localized: "titleImport.review.selectedWithLimit",
                    defaultValue: "\(selected) of \(total) (Limit: \(limit))",
                    comment: "Selected count, total and free-user limit"
                )
            }
            static let results = String(
                localized: "titleImport.review.results",
                defaultValue: "Results",
                comment: "Visible review result count"
            )
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
            static let continueButton = String(
                localized: "titleImport.review.continue",
                defaultValue: "Continue",
                comment: "Continue from title import review to confirmation"
            )
        }

        /// Provides localized text for the final import confirmation screen.
        enum Confirmation {
            static let title = String(localized: "titleImport.confirmation.title", defaultValue: "Confirm Import")
            static let selected = String(localized: "titleImport.confirmation.selected", defaultValue: "Selected")
            static let excluded = String(localized: "titleImport.confirmation.excluded", defaultValue: "Excluded")
            static let ambiguousIncluded = String(
                localized: "titleImport.confirmation.ambiguousIncluded",
                defaultValue: "Unclear Matches Included"
            )
            static let existingDuplicates = String(
                localized: "titleImport.confirmation.existingDuplicates",
                defaultValue: "Existing Library Duplicates"
            )
            static let fileDuplicates = String(
                localized: "titleImport.confirmation.fileDuplicates",
                defaultValue: "CSV Duplicates"
            )
            static let noMatch = String(localized: "titleImport.confirmation.noMatch", defaultValue: "No Match")
            static let failed = String(localized: "titleImport.confirmation.failed", defaultValue: "Failed Matches")
            static let estimatedTime = String(
                localized: "titleImport.confirmation.estimatedTime",
                defaultValue: "Estimated Minimum Time"
            )
            /// Formats a minimum estimated import duration.
            /// - Parameter seconds: The estimated minimum number of seconds.
            /// - Returns: The localized duration description.
            static func minimumSeconds(_ seconds: Int) -> String {
                String(
                    localized: "titleImport.confirmation.minimumSeconds",
                    defaultValue: "At least \(seconds) sec",
                    comment: "Minimum title import duration in seconds"
                )
            }
            static let importSelected = String(
                localized: "titleImport.confirmation.importSelected",
                defaultValue: "Import Selected"
            )
            static let back = String(localized: "titleImport.confirmation.back", defaultValue: "Back to Review")
        }

        /// Provides localized text for final media creation progress.
        enum FinalImport {
            static let title = String(localized: "titleImport.final.title", defaultValue: "Importing")
            /// Formats final-import progress.
            /// - Parameters:
            ///   - processed: The number of processed identities.
            ///   - total: The total number of identities in the attempt.
            /// - Returns: The localized progress description.
            static func progress(_ processed: Int, _ total: Int) -> String {
                String(
                    localized: "titleImport.final.progress",
                    defaultValue: "Processed \(processed) of \(total)",
                    comment: "Final title import progress"
                )
            }
            static let stop = String(localized: "titleImport.final.stop", defaultValue: "Stop Import")
        }

        /// Provides localized text for final import outcomes and actions.
        enum Summary {
            static let title = String(localized: "titleImport.summary.title", defaultValue: "Import Complete")
            static let imported = String(localized: "titleImport.summary.imported", defaultValue: "Imported")
            static let duplicates = String(
                localized: "titleImport.summary.duplicates",
                defaultValue: "Newly Detected Duplicates"
            )
            static let failed = String(localized: "titleImport.summary.failed", defaultValue: "Failed")
            static let remaining = String(localized: "titleImport.summary.remaining", defaultValue: "Remaining")
            static let retryFailed = String(
                localized: "titleImport.summary.retryFailed",
                defaultValue: "Retry Failed"
            )
            static let finish = String(localized: "titleImport.summary.finish", defaultValue: "Finish")
        }

        /// Provides localized text for safely stopping active work.
        enum StopConfirmation {
            static let title = String(localized: "titleImport.stop.title", defaultValue: "Stop Current Work?")
            static let message = String(
                localized: "titleImport.stop.message",
                defaultValue: "Current work stops safely. Completed imports stay in your library."
            )
            static let stop = String(localized: "titleImport.stop.action", defaultValue: "Stop")
        }

        /// Provides localized text for aborting and dismissing the import flow.
        enum DismissConfirmation {
            static let title = String(
                localized: "titleImport.dismiss.title",
                defaultValue: "Abort Import?",
                comment: "Title of confirmation dialog shown before dismissing title import"
            )
            static let message = String(
                localized: "titleImport.dismiss.message",
                defaultValue: "Your import progress and match selections will be lost.",
                comment: "Message shown before dismissing title import"
            )
            static let abort = String(
                localized: "titleImport.dismiss.action",
                defaultValue: "Abort Import",
                comment: "Destructive action that dismisses title import"
            )
        }

        /// Provides localized labels for review statuses.
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
