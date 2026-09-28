# Import Matching Learnings

This document records product and matching lessons learned while converting two iTunes exports for Movie DB. It focuses on observations and requirements that are not already represented by `Scripts/resolve_tmdb_ids.py`.

## Observed Results

| Import | Source records | Automatically accepted | Review rows | Final imported | Dropped |
| --- | ---: | ---: | ---: | ---: | ---: |
| Semicolon export | 1,710 | 1,593 | 117 | 1,693 | 17 |
| Headerless UK export | 1,539 | 1,389 | 150 | 1,531 | 8 |

The review sets had these characteristics:

- The semicolon export produced 100 ambiguous, 7 unmatched, and 10 duplicate rows.
- The UK export produced 139 ambiguous, 10 unmatched, and 1 duplicate row.
- Most ambiguous rows already had the correct top candidate. The exact-title requirement caused many false ambiguities.
- Some top candidates were confidently wrong because TMDB popularity outranked a less popular exact production.
- Manual review corrected movie IDs, detected TV miniseries, and removed alternate editions that mapped to an existing TMDB entry.

These results suggest that an in-app resolver can automate most rows, but must retain a review stage. It should optimize for reducing unnecessary review without silently accepting common-title or remake mismatches.

## Source Format Variability

The two exports did not share a schema.

### Headered Semicolon Export

Useful columns were:

- `Name`: title
- `Year`: year hint
- `Artist`: usually director
- `Total Time`: runtime

The export was valid semicolon-delimited CSV and included quoted multiline fields.

### Headerless Comma Export

The UK export was comma-delimited and had no header. Its useful positional columns were:

| Index | Meaning |
| ---: | --- |
| 1 | Title |
| 3 | Runtime |
| 4 | Director-like artist value |
| 5 | Genre |
| 7 | Store release date |
| 8 | Store year |
| 10 | Description |

It contained 1,564 parsed rows:

- 1,539 valid media rows
- 16 blank separator rows
- 9 description-continuation artifacts that looked like rows but lacked runtime and year

An app feature should not assume one iTunes schema. It needs delimiter/header detection followed by a column-mapping preview. Headerless data requires either a known format preset or explicit user mapping.

Rows should be validated structurally. A non-empty title alone is insufficient because malformed description fragments may occupy the title position.

## Metadata Reliability

### Title

Title was the best search input, but not a stable identifier. Store titles frequently contained regional naming, marketing text, edition labels, creator prefixes, or alternate numbering.

### Year

The exported year was often not the original release year. It could represent:

- Local theatrical release
- Digital store release
- Restoration release
- Extended-cut release
- Bundle publication
- Recent reissue

Observed differences ranged from one year to several decades. Examples included classic films carrying years from recent digital releases.

Year should be positive evidence when close, not a hard filter. A large mismatch should be tolerated when title, director, and runtime strongly identify the candidate.

Parenthesized years in titles were often more useful than the separate year field.

### Director-Like Artist Field

`Artist` was usually the director, but sometimes contained:

- `Unknown`
- A production company or brand
- A performer or music act
- A writer or producer
- A television series name
- Localized or non-Latin name forms
- Multiple names with comma, ampersand, or `and` separators

A matching director is strong evidence. A mismatch is weaker evidence because the source field is not trustworthy enough to veto an otherwise strong match.

Name comparison should handle diacritics, initials, punctuation, ordering, and localized forms. Person search can recover candidates when title search fails, as demonstrated by finding `Littekens` through director Martin Beek for the source title `Scars`.

### Runtime

Runtime was valuable for distinguishing remakes and common titles. It was less reliable for:

- Director's cuts
- Extended or unrated editions
- Split documentary parts
- TV miniseries exported as one long video
- Store metadata that includes or excludes credits

Runtime should use tolerance bands rather than exact equality. A close runtime is useful corroboration; a cut-specific mismatch should not reject a title/director match.

## Title Equivalence Patterns

### Number Representation

Equivalent titles used different number representations:

- `Alien 3` and `Alien³`
- `Evil Dead 2` and `Evil Dead II`
- `Jaws 3` and `Jaws 3-D`
- `Naked Gun 33 1/3` and `Naked Gun 33⅓`
- `The Accountant 2` and `The Accountant²`

Normalization should compare standalone Roman numerals, Arabic numbers, superscript digits, Unicode fractions, and common `3-D`/`3D` forms. Conversion must be token-aware so words and years are not accidentally rewritten.

### Added or Removed Subtitles

Store and TMDB titles often disagreed about subtitles:

- `Hotel Transylvania 3` / `Hotel Transylvania 3: Summer Vacation`
- `Peter Rabbit 2` / `Peter Rabbit 2: The Runaway`
- `The Accountant 2` / `The Accountant²`
- `Piranha` / `Piranha 3D`
- `House III: The Horror Show` / `The Horror Show`
- `Rocky IV: Rocky vs. Drago` / `Rocky IV`

The matcher should compare both full titles and title segments. A matching base title plus year/director/runtime can be high confidence, but removing a subtitle must not by itself create an exact match.

### Reordered Titles

Equivalent words appeared in different order:

- `Blair Witch 2: Book of Shadows` / `Book of Shadows: Blair Witch 2`
- `Friday the 13th Part VI: Jason Lives` / `Jason Lives - Friday the 13th Part VI`

Token similarity and franchise-number agreement are more useful than whole-string edit distance for these cases.

### Regional Titles

Observed regional aliases included:

- `Avengers Assemble` / `The Avengers`
- `Le Mans '66` / `Ford v Ferrari`
- `Battle Creek Brawl` / `The Big Brawl`
- `The Pirates! Band of Misfits` / `The Pirates! In an Adventure with Scientists!`
- `Nanny McPhee Returns` / `Nanny McPhee and the Big Bang`
- `The Transporter Refuelled` / `The Transporter Refueled`

TMDB alternative titles and translations should be included in candidate evidence where available. App language and region may otherwise make the correct alias less visible.

### Creator, Studio, and Franchise Prefixes

Sources added prefixes absent from TMDB:

- `Dr. Seuss'`
- `John Carpenter's`
- `Marvel Studios'`
- `Tim Burton's`
- `Wes Craven Presents`
- `Grindhouse`
- `Tales from the Crypt Presents`
- `The Divergent Series`
- `DCU`

Prefixes should become optional query variants only when other evidence supports removal. Generic prefix stripping could damage legitimate titles.

### Edition and Marketing Text

Additional observed labels included:

- `Final Cut`
- `Black & Chrome`
- `Complete Novel`
- `Commemorative Edition`
- `Extreme Edition`
- `Producer's Cut`
- `Super-Sized R Rated Version`
- `Ultimate Cut`
- `Includes 6 Disney Tales`
- `2021 Restoration` and `2023 Restoration`

Edition cleanup should support trailing text outside parentheses as well as parenthesized labels. It should generate search variants rather than destructively changing the source title.

For scoring, a trailing parenthesized known-edition label can be removed symmetrically from either source or candidate title. A colon-delimited subtitle can be removed from either side only when the source and candidate years match exactly; subtitle removal alone is not exact-title evidence.

An exact year can also qualify symmetric title containment when the shorter normalized title appears as a contiguous whole-token sequence in the longer title. Require at least two tokens so short titles such as `Up` do not match unrelated same-year titles such as `Up in the Air`.

### Unicode and Punctuation

Observed differences included:

- Curly and straight apostrophes
- Acute accents used as apostrophes
- Em dashes and hyphens
- Trademark symbols
- Non-breaking spaces
- Superscript numbers
- Unicode fractions
- Diacritics
- Non-Latin names and titles

Use Unicode-preserving normalization. Keep both a normalized Unicode representation and a transliterated comparison representation. An ASCII-only representation can collapse a non-Latin title to an empty string.

## Movie and TV Type Detection

An export that appears to contain movies can still include TV miniseries. Confirmed examples were:

- `Salem's Lot` (1979): TMDB TV
- `Salem's Lot` (2004): TMDB TV
- `It` (1990): TMDB TV

Searching only `/search/movie` misses these entries or selects an unrelated movie remake. Candidate discovery should use multi-search or search both movie and TV catalogs.

Movie details expose directors through credits. TV creators are not equivalent to directors, but TV credits can still contain the relevant director for a miniseries.

Media identity is `(MediaType, tmdbID)`, not TMDB ID alone. Import duplicate checks should use both values.

## Duplicate and Edition Semantics

TMDB generally models a work, not every store edition. These source rows mapped to the same TMDB entry:

- Theatrical and extended/unrated/director cuts
- Restorations
- Black-and-white or `Black & Chrome` editions
- Regional-title duplicates
- Documentary exports split into `Part One` and `Part Two`

Examples included split exports for `Crystal Lake Memories` and `Never Sleep Again`, plus alternate cuts of `The Martian`, `Rocky IV`, `Star Trek: The Motion Picture`, and `The Wicker Man`.

Movie DB currently cannot represent separate editions sharing one TMDB identity. The review UI should explain this and default later duplicates to drop. It should show the source row already claiming the ID.

Duplicate detection must run across:

- Existing library entries
- Automatically accepted rows
- Manually accepted rows
- Ambiguous rows that resolve to the same candidate

The last case is easy to miss when ambiguous rows are not reserved during the automatic pass.

## Search Lessons

- TMDB page-one popularity ordering can rank an unrelated short, remake, or future production above the correct candidate.
- A full store title can return no results while a reduced title immediately finds the correct result.
- Search sometimes requires multiple pages for generic titles such as `Wolf`.
- Person search can recover obscure or alternate-title films when title search fails.
- Search results may reference a resource whose detail endpoint returns `404`; skip that candidate rather than aborting the import.
- Original title, translated title, alternative titles, year, director, and runtime should all contribute evidence.
- Search should broaden progressively. Running every fallback for every row would create unnecessary API traffic.

Recommended candidate discovery order:

1. Search the raw title using multi-search.
2. Search safe title variants generated from edition/year cleanup.
3. Search normalized number and punctuation variants.
4. Search base-title and subtitle variants.
5. Search movie and TV endpoints with useful year hints, but without making year mandatory.
6. Fetch details and credits for the strongest few candidates.
7. For unresolved rows with a reliable person name, use person credits as a constrained fallback.
8. Search additional pages only for generic titles or when no candidate has strong evidence.

## Confidence Policy

Exact normalized title should not be mandatory. The UK review showed that many obvious regional titles and subtitle differences had strong director/year/runtime evidence but were classified ambiguous.

Suggested confidence behavior:

- Auto-accept exact or known-alias title with close year when candidate lead is clear.
- Auto-accept a strong non-exact title when director matches and either year or runtime corroborates it.
- Allow large year mismatch when title, director, and runtime strongly agree.
- Require review for common titles when director is absent or mismatched.
- Require review when two candidates remain close after detail scoring.
- Require review when only popularity distinguishes candidates.
- Never auto-accept a candidate solely because it is the only search result.
- Treat known edition variants as duplicate candidates when the base work already exists.

The score should expose evidence, not only a number. Useful explanations include:

- Title alias matched
- Director matched
- Runtime within tolerance
- Store year differs from original release
- TV candidate selected over movie remake
- Duplicate of another source row

## In-App Workflow Requirements

The resolver should be a staged import, separate from the existing direct TMDB-ID CSV importer.

Suggested stages:

1. Pick file.
2. Detect delimiter, header, encoding, and candidate schema.
3. Map title, year, director, runtime, and optional type columns.
4. Preview parsed rows and reject malformed records.
5. Resolve candidates with progress, cancellation, retries, and request caching.
6. Present groups for accepted, needs review, no match, and duplicate.
7. Allow candidate search, type switching, include/drop decisions, and bulk approval.
8. Re-run deduplication after manual decisions.
9. Show final counts before creating Core Data objects.
10. Commit through the existing import context so the entire operation remains undoable.

Review rows should show source metadata beside candidate metadata:

- Source and candidate titles
- Media type
- Source and candidate years
- Source and candidate director names
- Source and candidate runtimes
- Poster
- Confidence evidence
- Duplicate owner, when applicable

Do not create temporary `Media` objects while matching. Resolve into lightweight value types first, then fetch full TMDB data only for final included entries.

## Operational Requirements

- Imports of roughly 1,500 rows generate thousands of requests when details are fetched for several candidates.
- Cache search and detail responses for the duration of the import.
- Preserve progress if the app moves to the background where practical.
- Support cancellation between rows and before detail requests.
- Retry throttling and server failures with bounded backoff.
- Treat candidate-level `404` responses as recoverable.
- Keep source row numbers stable through parsing and review.
- Preserve unknown source columns until final export or commit where useful.

Imported titles, notes, descriptions, IDs, and file contents are private user data. They must not be added to analytics. Any future analytics should remain aggregate, allowlisted, opt-in, and require the normal approval/documentation process.

## Regression Cases

The following cases should become sanitized unit-test fixtures for a native matcher:

| Source | Expected TMDB title | Lesson |
| --- | --- | --- |
| `Alien 3` | `Alien³` | Superscript number |
| `Evil Dead 2` | `Evil Dead II` | Roman numeral |
| `The Accountant 2` | `The Accountant²` | Superscript number |
| `Blair Witch 2: Book of Shadows` | `Book of Shadows: Blair Witch 2` | Reordered title |
| `Avengers Assemble` | `The Avengers` | Regional title |
| `Le Mans '66` | `Ford v Ferrari` | Unrelated regional alias |
| `The Pirates! Band of Misfits` | `The Pirates! In an Adventure with Scientists!` | Regional subtitle |
| `Birdman` | `Birdman or (The Unexpected Virtue of Ignorance)` | Missing subtitle and wrong popular result |
| `Blood Lake` | `Blood Lake: Attack of the Killer Lampreys` | Missing subtitle |
| `Scars` | `Littekens` | Alternate title found through director |
| `Crossroads`, Walter Hill | `Crossroads` (1986) | Common title, wrong store year |
| `Crossroads`, Tamra Davis | `Crossroads` (2002) | Director disambiguation |
| `Piranha`, Alexandre Aja | `Piranha 3D` | Missing suffix and wrong exact-title result |
| `Prom Night (1980)` | `Prom Night` (1980) | Store year differs by decades |
| `Salem's Lot`, Tobe Hooper | `Salem's Lot` (TV, 1979) | TV miniseries in movie export |
| `Stephen King's IT` | `It` (TV, 1990) | TV miniseries and creator prefix |
| `Rocky IV: Rocky vs. Drago` | `Rocky IV` | Alternate cut duplicates base work |
| `Crystal Lake Memories - Part 2` | Same ID as Part 1 | Split export duplicate |
| Non-Latin-only candidate title | No crash | Empty transliteration safety |
| Search candidate with missing detail resource | Skip candidate | Recoverable `404` |

Use synthetic or minimized fixture data rather than committing complete user exports.

## Scope Guidance

A first in-app version should support mapped `title`, `year`, `director`, and `runtime` columns plus a mandatory review screen. Generic format presets, person-credit fallback, alternative-title fetching, and import-session persistence can follow incrementally.

The feature is primarily a matching and review problem, not a TMDB API problem. Existing TMDB search, detail fetching, import contexts, progress UI, and CSV infrastructure are reusable. The largest new components are schema mapping, a native resolver, and a review workflow.
