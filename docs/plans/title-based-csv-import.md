# Title-Based CSV Import Plan

## Scope

Add a separate title-based CSV import option in Settings. The importer identifies useful columns from localized header aliases, searches TMDB for each source row, ranks candidates using deterministic matching logic, and presents a complete review list before importing full TMDB data.

The existing exact TMDB-ID importer remains available for Movie DB exports containing `tmdb_id` and `type`.

## Product Decisions

- Support CSV files only. Do not support Excel workbooks or other spreadsheet formats.
- Require a header row.
- Require one user-confirmed title-column mapping before resolution.
- Use optional year, director, runtime, and media-type columns as matching evidence.
- Support English and German header aliases regardless of the selected app language.
- Make accepted matches included by default.
- Make ambiguous matches excluded by default, but allow the user to include the proposed top candidate.
- Keep no-match rows visible and locked excluded.
- Keep existing-library and intra-file duplicates visible and locked excluded.
- Allow users to include or exclude results, but not select another TMDB candidate in the first version.
- Use CSV metadata only as match hints. Do not import ratings, notes, tags, or watch state through this flow.
- Permit partial final imports. Keep failed items retryable during the current session.
- Limit free users to 25 total library items. Pro users have no import row limit.
- Add no new analytics without separate approval and an `ANALYTICS.md` update.

## Explicit Non-Goals

- Background processing or continuation
- Checkpoints or restoration after app restart
- AI-based matching
- Manual candidate selection or manual TMDB search
- Excel, Numbers, or OpenDocument spreadsheet files

## User Flow

1. Open Settings and choose the new title-based CSV import action.
2. Pick a CSV file.
3. Parse the file and detect its delimiter and supported columns.
4. Show preflight information, editable column mappings, and any recoverable warnings.
5. Start foreground TMDB resolution.
6. Show progress with processed and total row counts plus cancellation.
7. After every row is processed, show the complete review list.
8. Let the user include or exclude eligible matches.
9. Confirm the final selection.
10. Load complete TMDB data and create media objects.
11. Show imported, duplicate, and failed counts.
12. Allow failed imports to be retried before leaving the session.

## 1. Settings Entry

Add a second media import action under the existing Import/Export section, named along the lines of "Import CSV by Title." Present the workflow in a dedicated full-screen `NavigationStack` because it has multiple stages and can run for a long time.

Keep the existing media import action for exact Movie DB backup files. Its label should distinguish it from the new title-matching import.

## 2. CSV Preflight

Read the security-scoped file completely while access is active, then release access using `defer`. Keep only owned parsed data after that point.

Supported behavior:

- Accept files exposed as comma-separated text.
- Accept comma-delimited and semicolon-delimited CSV content.
- Support UTF-8 and UTF-8 with a byte-order mark.
- Preserve quoted fields, embedded delimiters, and quoted multiline values.
- Ignore fully empty rows.
- Keep original source row numbers stable through matching and review.
- Do not impose a product row limit for Pro users.
- Target reliable operation with at least 10,000 rows.

Reject files with:

- No header row
- No data rows
- Invalid CSV structure
- Unsupported text encoding

The preflight screen should show:

- Parsed row count
- Detected delimiter
- Editable title and optional-column mappings
- Ignored columns
- Empty or malformed row count
- Warnings for optional fields that could not be used

Keep raw rows through preflight so users can correct missing or ambiguous automatic mappings. Disable resolution until a title column is selected and contains at least one usable title. Apply every confirmed mapping only when materializing normalized source rows for resolution.

## 3. Header Recognition

Define these matching fields:

- `title`, required
- `year`, optional
- `director`, optional
- `runtime`, optional
- `mediaType`, optional

Normalize headers before comparison:

- Trim whitespace and newlines.
- Apply Unicode compatibility normalization.
- Compare case-insensitively and diacritic-insensitively.
- Treat spaces, underscores, and hyphens as equivalent separators.
- Collapse repeated separators.

Initial English aliases should include forms such as:

| Field | Aliases |
| --- | --- |
| Title | `title`, `name`, `movie title`, `film`, `media title` |
| Year | `year`, `release year`, `release date`, `date` |
| Director | `director`, `directors`, `artist` |
| Runtime | `runtime`, `duration`, `length`, `total time` |
| Media type | `type`, `media type`, `kind` |

Initial German aliases should include forms such as:

| Field | Aliases |
| --- | --- |
| Title | `titel`, `name`, `film`, `filmtitel`, `medientitel` |
| Year | `jahr`, `erscheinungsjahr`, `veröffentlichungsjahr`, `veröffentlichungsdatum` |
| Director | `regisseur`, `regisseure`, `regie`, `künstler` |
| Runtime | `laufzeit`, `dauer`, `gesamtdauer` |
| Media type | `typ`, `medientyp`, `art` |

English parser vocabulary is always active as a fallback. Merge it with vocabulary from the current app localization. Store localized aliases as pipe-separated String Catalog values so adding an app language requires translations, not Swift changes. Keep separate localized year groups for exact year, release year, release date, and generic date aliases so canonical-name priority remains deterministic.

If multiple optional columns map to one field, use deterministic canonical-name priority. If no unique optional column can be selected, ignore that hint and display a preflight warning rather than rejecting an otherwise valid file.

## 4. Source Value Parsing

Keep original strings for display and derive typed matching hints separately.

Year parsing should support:

- A four-digit year
- A date containing a four-digit year
- A parenthesized year in the title as a fallback
- A reasonable validation range

Runtime parsing should support:

- Integer minutes
- `h:mm`
- `h:mm:ss`
- `h:mm:ss.SSS`
- `mm:ss.SSS`
- Common minute suffixes where unambiguous

Director parsing should:

- Ignore empty and localized `Unknown` values.
- Split common list separators.
- Load localized unknown values and conjunctions from the String Catalog.
- Preserve original names for review.
- Normalize initials, punctuation, ordering, and diacritics for comparison.

Runtime unit suffixes and media-type values should use the same English-plus-current-localization vocabulary. Media type remains strong evidence, not a hard filter, because movie exports can contain TV miniseries.

## 5. Import Models

Keep resolution independent from Core Data. Use lightweight value types that can safely cross concurrency domains.

Suggested types:

- `ImportSourceRow`: stable row ID, source row number, raw values, and parsed hints
- `MediaIdentity`: `MediaType` plus TMDB ID
- `ImportCandidate`: lightweight TMDB search/detail values
- `ImportMatchEvidence`: title, year, director, runtime, and type evidence
- `ImportMatchStatus`: accepted, ambiguous, duplicate, no match, or failed
- `ImportReviewItem`: source row, selected candidate, status, reason, and inclusion state
- `ImportSessionSummary`: aggregate counts for preflight, review, and final import

Do not create temporary `Media` managed objects while searching or scoring.

## 6. TMDB Matching API

Add a testable TMDB provider abstraction with lightweight methods for matching. Do not use full Core Data-backed media decoding during resolution.

Required operations:

- Page-one `/search/multi`
- Additional search pages when escalation rules require them
- Minimal movie details and credits
- Minimal TV details and credits
- Alternative titles when ambiguity requires them

Use the existing configured TMDB language and region. Identify every candidate by `(MediaType, tmdbID)` because movie and TV IDs can overlap.

The provider should expose value types containing only matching data:

- TMDB ID and media type
- Display and original titles
- Alternative titles when loaded
- Release or first-air year
- Runtime or episode runtimes
- Director or creator names
- Poster path
- Popularity for tie-breaking only

## 7. Matching Engine

Implement deterministic matching as pure scoring logic around the async TMDB provider.

### Candidate Discovery

Use progressive search to avoid unnecessary requests:

1. Search the raw source title using multi-search.
2. Score display and original titles from page one.
3. Search safe year and edition-cleaned title variants if confidence remains low.
4. Search number, punctuation, subtitle, and prefix variants progressively.
5. Load minimal details for the strongest uncertain candidates.
6. Include alternative titles in rescoring when details provide them.
7. Search additional pages only when no candidate has strong evidence.

Do not run every fallback for every source row.

### Title Normalization

Support the patterns recorded in `docs/ImportMatchingLearnings.md`:

- Unicode compatibility forms
- Diacritics and punctuation differences
- Curly and straight apostrophes
- Dash variants
- Trademark symbols and non-breaking spaces
- Superscript digits
- Unicode fractions
- Arabic and standalone Roman numeral equivalence
- Parenthesized years
- Edition and restoration labels
- Added or removed subtitles
- Reordered franchise titles
- Known creator, studio, and franchise prefixes
- Unicode-preserving and transliterated comparison forms

Generate query variants without destructively replacing the source title.

### Scoring

Rank evidence approximately in this order:

1. Display, original, or alternative title match
2. Normalized title and token similarity
3. Release-year distance
4. Director agreement
5. Runtime tolerance
6. Optional media-type agreement
7. TMDB popularity as a final tie-breaker only

Director matches are strong positive evidence. Director mismatches are weaker negative evidence because source artist columns are unreliable.

Runtime uses tolerance bands. TV runtime evidence should be weighted more weakly than movie runtime because source files may contain total miniseries runtime while TMDB exposes episode runtimes.

Year is positive evidence when close, but not a hard filter. Large year differences remain acceptable when title, director, and runtime strongly agree.

### Confidence Classification

Classify the best candidate using both:

- A minimum score
- A minimum score lead over the runner-up

Exact normalized title is strong evidence, not a mandatory condition.

Treat titles as equivalent when one side differs only by a trailing parenthesized known-edition label. Treat a colon-delimited base-title match as title evidence only when source and candidate years match exactly. Apply both comparisons symmetrically to display, original, and alternative candidate titles. Confidence still requires the normal score margin over the runner-up.

Outcomes:

- `accepted`: score and margin are sufficient
- `ambiguous`: a top candidate exists but confidence or margin is insufficient
- `noMatch`: no plausible candidate exists
- `failed`: candidate resolution could not complete because of an operational error

Store human-readable evidence instead of only a numeric score. Examples include title alias match, close release year, matching director, close runtime, movie/TV disagreement, and low margin.

## 8. Large-Import Execution

Use an actor-owned resolver session with a bounded worker pool. Do not create one simultaneous task per source row.

Use import-scoped caches for:

- Search query plus language and region
- Candidate details by `MediaIdentity`
- Existing library identities

Repeated source titles should share cached searches and details.

Throttle progress updates sent to the main actor. Update by batch or a limited frequency instead of mutating UI state after every row.

Use the existing global TMDB request throttle. Add bounded retries for rate limits, server failures, and transient network errors. Respect `Retry-After` where provided. Treat candidate-level `404` responses as recoverable and skip that candidate.

Disable idle sleep while foreground resolution or final import is running, then restore the previous setting. Cancellation discards unresolved session state because persistence and checkpoints are out of scope.

### Expected 10,000-Row Behavior

- Memory remains O(row count).
- Review UI uses lazy rendering and stable identity.
- At 20 requests per second, one search request per row has a theoretical minimum near 8-9 minutes.
- Final full-detail loading can add a similar minimum if all 10,000 rows are imported.
- Additional candidate-detail calls occur only for uncertain rows.
- The app must remain active because background continuation is not included.

## 9. Deduplication

Fetch existing library identities once before processing instead of issuing one Core Data query per candidate.

Detect:

- Candidate already present in the library
- Multiple source rows resolving to the same identity
- Identity added through CloudKit or another app action after matching but before final import

The first source occurrence owns an intra-file identity. Later occurrences show the owner row and remain locked excluded. Since this flow imports no per-row user metadata, choosing a later duplicate would create the same library object.

Run deduplication again immediately before each final media import. Newly detected duplicates should be skipped and reported rather than treated as failures.

## 10. Review Screen

Render a lazy list only after all rows finish resolving.

Provide filters for:

- All
- Included
- Ambiguous
- Duplicates
- No match
- Failed

Support search within the review list by source title and matched TMDB title.

Each row should show:

- Source title
- Source year, director, runtime, and media type when present
- Selected TMDB title
- TMDB movie or TV type
- TMDB year
- Poster
- Confidence status
- Match evidence or ambiguity reason
- Duplicate owner when applicable
- Include toggle when eligible

Selection rules:

- Accepted rows start included.
- Ambiguous rows start excluded.
- Users may include an ambiguous row, accepting its proposed top candidate.
- Users may exclude accepted or ambiguous rows.
- Duplicate, no-match, and failed rows remain locked excluded.

For free users, the selected count cannot exceed the remaining slots before the 25-item library limit. Users may exchange selections by excluding one item and then including another. If the library already contains 25 items, present the existing Pro information flow before resolution begins.

## 11. Confirmation

Before loading full TMDB data, show:

- Selected count
- Excluded count
- Ambiguous matches explicitly included
- Existing-library duplicate count
- Intra-file duplicate count
- No-match count
- Failed-resolution count
- Estimated minimum processing time based on selected count and current request throttle

Leaving the workflow before confirmation discards the in-memory session.

## 12. Final Import

Freeze selected identities when confirmation starts. Import through background Core Data contexts without passing managed objects across tasks.

Use a background writer context and isolate each item with a child context:

1. Recheck the media identity against the persistent library.
2. Fetch and decode complete TMDB data in the child context.
3. Create the `Media` object in that child context.
4. Save the child into the writer context only on success.
5. Roll back and discard the child context on failure.
6. Save and reset the writer context in bounded batches.

Process items sequentially or with tightly bounded concurrency that preserves Core Data isolation. Avoid sharing managed objects or managed object contexts between child tasks.

Do not eagerly start thousands of poster downloads. Store TMDB image paths during import and load thumbnails lazily for visible library rows. Existing one-item add flows may retain eager image loading.

After confirmation, successfully saved batches remain imported even if later items fail or the user stops the operation.

The final summary should show:

- Imported count
- Newly detected duplicate count
- Failed count
- Remaining count if stopped
- Retry failed action
- Finish action

Retries exist only while the current in-memory session remains open.

## 13. State Management

Use a `@MainActor @Observable` workflow model for:

- Current workflow stage
- Preflight result
- Resolution progress
- Review items
- Active filters and search text
- Inclusion state and free-user limit enforcement
- Final import progress
- Cancellation and errors

Keep parser, normalizer, scorer, resolver, deduplicator, and final importer independent from SwiftUI and independently testable.

Own long-running tasks in the workflow model. Cancel them when the flow closes. Require confirmation before dismissing during active resolution or final import.

## 14. Localization

Route all user-facing text through `Strings` and `Localizable.xcstrings`. Add English and German translations for:

- Settings actions
- Preflight labels and errors
- Resolution progress
- Review statuses and filters
- Match evidence
- Selection-limit messages
- Confirmation summary
- Final import progress and summary

Header aliases are parser configuration, not visible localization strings.

## 15. Analytics and Privacy

Do not add analytics for the new workflow without explicit approval.

Never log or track source titles, TMDB IDs, directors, file names, file URLs, raw rows, search queries, or other imported content. OSLog messages containing content must remain private.

If analytics are approved later, restrict them to allowlisted aggregate buckets and update `ANALYTICS.md` before implementation.

## 16. Testing

### Parser Tests

- Comma and semicolon detection
- UTF-8 byte-order mark
- Quoted delimiters
- Quoted multiline values
- Empty and malformed rows
- English and German header aliases
- Header normalization
- Missing title header remains editable in preflight
- Ambiguous title headers remain editable in preflight
- Required title mapping and empty-title-column validation
- Manual mappings affect parsed source metadata
- Optional-header conflicts
- Year, runtime, director, and media-type parsing
- At least 10,000 synthetic rows

### Matcher Tests

- Exact title and year
- Roman and Arabic numerals
- Superscript digits and Unicode fractions
- Edition and restoration suffixes
- Added, removed, and reordered subtitles
- Regional and alternative titles
- Creator and studio prefixes
- Large year mismatch corrected by director and runtime
- Common-title director disambiguation
- Movie and TV results sharing an ID
- TV miniseries in movie-oriented exports
- Low score and low margin ambiguity
- No results
- Recoverable candidate `404`
- Rate-limit and transient-failure retries
- Search and detail cache reuse
- Cancellation

Use sanitized regression cases from `docs/ImportMatchingLearnings.md`.

### Deduplication and Selection Tests

- Existing-library duplicate
- Intra-file duplicate
- Movie and TV identity separation
- Duplicate discovered immediately before import
- Accepted default inclusion
- Ambiguous default exclusion
- Locked no-match and duplicate rows
- Free-user remaining-slot calculation
- Exchanging free-user selections
- Unlimited Pro selection

### Core Data Import Tests

- Successful full-detail import
- Failed item rollback without partial managed objects
- Batched writer saves
- Partial success behavior
- Retry of failed identities
- Duplicate appearing during the session
- No managed-object handoff across contexts
- Lazy thumbnail behavior

### UI Tests

- New Settings action
- Invalid CSV error
- Preflight summary
- Progress and cancellation
- Review filtering and searching
- Inclusion toggles
- Ambiguous highlighting
- Duplicate locking
- Free-user selection cap
- Confirmation summary
- Partial-failure and retry summary

### Performance Tests

- Parse 10,000 synthetic rows.
- Score 10,000 mocked candidate sets.
- Build and filter 10,000 review items.
- Verify bounded active work and stable memory growth.
- Verify progress updates are throttled.

## 17. Delivery Order

1. Implement parser, aliases, source models, and parser tests.
2. Implement title normalization, variants, scoring, and regression tests.
3. Add lightweight TMDB matching provider, cache, and retry behavior.
4. Implement resolver orchestration and 10,000-row performance tests.
5. Add Settings entry, file picker, preflight, and progress UI.
6. Add review list, filters, inclusion state, and product-limit handling.
7. Add batched Core Data final import, partial-failure handling, and retries.
8. Add lazy bulk-import thumbnail behavior.
9. Add English and German localization.
10. Add UI tests and run full build/test verification.

## Acceptance Criteria

- A valid CSV can enter resolution after the user confirms a title-column mapping.
- Missing or ambiguous automatic title mappings remain editable in preflight instead of ending the workflow.
- Optional year, director, runtime, and media type improve deterministic matching.
- Movie and TV candidates are both considered.
- At least 10,000 rows can be parsed, resolved, reviewed, and imported without unbounded task or memory growth.
- Every source row receives an accepted, ambiguous, duplicate, no-match, or failed review state.
- Ambiguous rows start excluded and can be explicitly included.
- Duplicates and no-match rows remain visible and locked excluded.
- Free-user selection never permits the library to exceed 25 items.
- Pro users have no artificial row or selection limit.
- No Core Data objects are created before final confirmation.
- Final import preserves successes when individual items fail.
- Failed final imports can be retried during the current session.
- No imported content is sent to analytics.
- Existing exact TMDB-ID import behavior remains available.
