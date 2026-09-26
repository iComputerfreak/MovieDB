// Copyright © 2026 Jonas Frey. All rights reserved.

@testable import Movie_DB
import Foundation
import Testing

@Suite("Title-based CSV import")
struct TitleImportTests {
    @Test("Parses English comma-separated columns")
    func parsesEnglishCSV() throws {
        let csv = """
        Name,Year,Director,Runtime,Type,Ignored
        "Alien, The",1979,Ridley Scott,117,movie,value
        """
        let result = try TitleImportCSVParser().parse(string: csv)
        let row = try #require(result.rows.first)

        #expect(result.delimiter == ",")
        #expect(row.title == "Alien, The")
        #expect(row.year == 1979)
        #expect(row.directors == ["Ridley Scott"])
        #expect(row.runtimeMinutes == 117)
        #expect(row.mediaType == .movie)
        #expect(result.ignoredHeaders == ["Ignored"])
    }

    @Test("Parses German semicolon-separated columns")
    func parsesGermanCSV() throws {
        let csv = """
        Titel;Erscheinungsjahr;Regie;Laufzeit;Medientyp
        Dark;2017;Baran bo Odar;0:53:00;Serie
        """
        let row = try #require(TitleImportCSVParser().parse(string: csv).rows.first)

        #expect(row.title == "Dark")
        #expect(row.year == 2017)
        #expect(row.directors == ["Baran bo Odar"])
        #expect(row.runtimeMinutes == 53)
        #expect(row.mediaType == .show)
    }

    @Test("Rejects missing and ambiguous title headers")
    func rejectsInvalidHeaders() {
        #expect(throws: TitleImportCSVParser.ParserError.self) {
            try TitleImportCSVParser().parse(string: "Year,Director\n1999,Lana Wachowski")
        }
        #expect(throws: TitleImportCSVParser.ParserError.self) {
            try TitleImportCSVParser().parse(string: "Title,Name\nThe Matrix,The Matrix")
        }
    }

    @Test(
        "Parses supported runtime formats",
        arguments: [
            ("119", 119),
            ("1:59", 119),
            ("1:59:16.157", 119),
            ("47:33.953", 48),
            ("90 minutes", 90),
        ]
    )
    func parsesRuntime(value: String, expected: Int) {
        #expect(TitleImportCSVParser.parseRuntime(value) == expected)
    }

    @Test(
        "Normalizes equivalent title numbers",
        arguments: [
            ("Alien 3", "Alien³"),
            ("Evil Dead II", "Evil Dead 2"),
            ("Naked Gun 33 ⅓", "Naked Gun 33 1/3"),
        ]
    )
    func normalizesNumbers(left: String, right: String) {
        #expect(TitleImportTitleMatcher.normalize(left) == TitleImportTitleMatcher.normalize(right))
    }

    @Test("Preserves non-Latin title words")
    func preservesUnicodeTitles() {
        #expect(TitleImportTitleMatcher.normalize("東京物語") == "東京物語")
    }

    @Test("Does not strip title prefixes")
    func preservesTitlePrefixes() {
        let variants = TitleImportTitleMatcher.variants(for: "John Carpenter's Vampires")
            .map(TitleImportTitleMatcher.normalize)

        #expect(variants == ["john carpenter s vampires"])
    }

    @Test("Generates edition and subtitle variants")
    func generatesTitleVariants() {
        let variants = TitleImportTitleMatcher.variants(for: "Rocky IV: Rocky vs. Drago (Ultimate Cut)")
            .map(TitleImportTitleMatcher.normalize)

        #expect(variants.contains("rocky 4 rocky vs drago"))
        #expect(variants.contains("rocky 4"))
    }

    @Test("Director and runtime overcome an incorrect year")
    func scoresCorroboratingDetails() {
        let source = sourceRow(title: "Crossroads", year: 2020, director: "Walter Hill", runtime: 99)
        let candidate = candidate(
            id: 1,
            title: "Crossroads",
            year: 1986,
            directors: ["Walter Hill"],
            runtime: 99
        )
        let result = TitleImportScorer().score(candidate, for: source)

        #expect(result.score >= 100)
        #expect(result.evidence.titleMatch)
        #expect(result.evidence.directorMatch)
        #expect(result.evidence.runtimeMatch)
    }

    @Test("Resolver caches repeated searches")
    @MainActor
    func cachesSearches() async throws {
        let candidate = candidate(id: 603, title: "The Matrix", year: 1999)
        let provider = MockTitleImportProvider(searchResults: ["The Matrix": [candidate]])
        let resolver = TitleImportResolver(provider: provider, workerCount: 2)
        let rows = [
            sourceRow(id: 2, title: "The Matrix", year: 1999),
            sourceRow(id: 3, title: "The Matrix", year: 1999),
        ]

        let results = try await resolver.resolve(rows) { _ in }

        #expect(results.allSatisfy { $0.status == .accepted })
        #expect(await provider.searchCallCount == 1)
    }

    @Test("Resolver enriches uncertain candidates")
    @MainActor
    func enrichesCandidates() async throws {
        let candidate = candidate(id: 2, title: "Piranha 3D", year: 2010)
        let provider = MockTitleImportProvider(
            searchResults: ["Piranha": [candidate]],
            details: [
                candidate.identity: TitleImportCandidateDetails(
                    alternativeTitles: ["Piranha"],
                    directors: ["Alexandre Aja"],
                    runtimeMinutes: 88
                ),
            ]
        )
        let source = sourceRow(title: "Piranha", year: 2010, director: "Alexandre Aja", runtime: 88)

        let result = try #require(try await TitleImportResolver(provider: provider).resolve([source]) { _ in }.first)

        #expect(result.status == .accepted)
        #expect(result.evidence.alternativeTitleMatch)
        #expect(result.evidence.directorMatch)
    }

    @Test("Deduplicates by media type and TMDB ID")
    func deduplicatesIdentities() {
        let movie = candidate(id: 10, type: .movie, title: "Example", year: 2020)
        let show = candidate(id: 10, type: .show, title: "Example", year: 2020)
        let items = [
            reviewItem(id: 2, candidate: movie),
            reviewItem(id: 3, candidate: movie),
            reviewItem(id: 4, candidate: show),
        ]

        let results = TitleImportDeduplicator.apply(to: items, existingIdentities: [show.identity])

        #expect(results[0].status == .accepted)
        #expect(results[1].status == .duplicate)
        #expect(results[2].status == .duplicate)
    }

    @Test("Parses 10,000 rows")
    func parsesLargeCSV() throws {
        let rows = (1...10_000).map { "Movie \($0),2000" }.joined(separator: "\n")
        let result = try TitleImportCSVParser().parse(string: "Title,Year\n\(rows)")

        #expect(result.rows.count == 10_000)
        #expect(result.rows.last?.title == "Movie 10000")
    }

    private func sourceRow(
        id: Int = 2,
        title: String,
        year: Int?,
        director: String? = nil,
        runtime: Int? = nil
    ) -> TitleImportSourceRow {
        TitleImportSourceRow(
            id: id,
            title: title,
            year: year,
            directors: director.map { [$0] } ?? [],
            runtimeMinutes: runtime,
            mediaType: nil
        )
    }

    private func candidate(
        id: Int,
        type: MediaType = .movie,
        title: String,
        year: Int?,
        directors: [String] = [],
        runtime: Int? = nil
    ) -> TitleImportCandidate {
        TitleImportCandidate(
            identity: MediaIdentity(type: type, tmdbID: id),
            title: title,
            originalTitle: title,
            year: year,
            imagePath: nil,
            popularity: 1,
            alternativeTitles: [],
            directors: directors,
            runtimeMinutes: runtime
        )
    }

    private func reviewItem(id: Int, candidate: TitleImportCandidate) -> TitleImportReviewItem {
        TitleImportReviewItem(
            id: id,
            source: sourceRow(id: id, title: candidate.title, year: candidate.year),
            candidate: candidate,
            status: .accepted,
            reason: "",
            evidence: TitleImportMatchEvidence(titleMatch: true),
            isIncluded: true
        )
    }
}

private actor MockTitleImportProvider: TitleImportTMDBProviding {
    private let searchResults: [String: [TitleImportCandidate]]
    private let details: [MediaIdentity: TitleImportCandidateDetails]
    private(set) var searchCallCount = 0

    init(
        searchResults: [String: [TitleImportCandidate]],
        details: [MediaIdentity: TitleImportCandidateDetails] = [:]
    ) {
        self.searchResults = searchResults
        self.details = details
    }

    func titleImportSearch(_ query: String, page: Int) async throws -> [TitleImportCandidate] {
        searchCallCount += 1
        return page == 1 ? searchResults[query, default: []] : []
    }

    func titleImportDetails(for identity: MediaIdentity) async throws -> TitleImportCandidateDetails {
        details[identity] ?? TitleImportCandidateDetails(
            alternativeTitles: [],
            directors: [],
            runtimeMinutes: nil
        )
    }
}
