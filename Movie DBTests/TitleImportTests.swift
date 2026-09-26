// Copyright © 2026 Jonas Frey. All rights reserved.

@testable import Movie_DB
import CoreData
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
        let result = try TitleImportCSVParser(locale: Locale(identifier: "de")).parse(string: csv)
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
        Dark;2017;Baran bo Odar und Jantje Friese;53 Minuten;Serie
        """
        let locale = Locale(identifier: "de")
        let row = try #require(TitleImportCSVParser(locale: locale).parse(string: csv).rows.first)

        #expect(row.title == "Dark")
        #expect(row.year == 2017)
        #expect(row.directors == ["Baran bo Odar", "Jantje Friese"])
        #expect(row.runtimeMinutes == 53)
        #expect(row.mediaType == .show)
        #expect(TitleImportCSVParser.parseDirectors("Unbekannt", locale: locale).isEmpty)
    }

    @Test("Uses only English and the active localization")
    func usesActiveLocalization() {
        #expect(throws: TitleImportCSVParser.ParserError.self) {
            try TitleImportCSVParser(locale: Locale(identifier: "en")).parse(string: """
            Titel,Jahr
            Dark,2017
            """)
        }
    }

    @Test("Prioritizes dedicated year columns over release dates")
    func prioritizesYearColumns() throws {
        let explicitYear = try TitleImportCSVParser().parse(string: """
        Title,Year,Release Date
        Alien,1979,1979-05-25
        """)
        let releaseYear = try TitleImportCSVParser().parse(string: """
        Title,Release Year,Date
        Alien,1979,1979-05-25
        """)
        let releaseDate = try TitleImportCSVParser().parse(string: """
        Title,Release Date
        Alien,1979-05-25
        """)

        #expect(explicitYear.rows.first?.year == 1979)
        #expect(explicitYear.mappedHeaders[.year] == "Year")
        #expect(explicitYear.ignoredHeaders == ["Release Date"])
        #expect(releaseYear.mappedHeaders[.year] == "Release Year")
        #expect(releaseYear.ignoredHeaders == ["Date"])
        #expect(releaseDate.rows.first?.year == 1979)
        #expect(releaseDate.mappedHeaders[.year] == "Release Date")
    }

    @Test("Ignores tied optional headers")
    func ignoresTiedOptionalHeaders() throws {
        let result = try TitleImportCSVParser(locale: Locale(identifier: "de")).parse(string: """
        Title,Year,Jahr
        Alien,1979,1980
        """)

        #expect(result.rows.first?.year == nil)
        #expect(result.mappedHeaders[.year] == nil)
        #expect(result.ignoredHeaders == ["Year", "Jahr"])
    }

    @Test(
        "Rejects years outside the accepted range",
        arguments: ["1799", "2200", "unknown"]
    )
    func rejectsInvalidYears(_ value: String) {
        #expect(TitleImportCSVParser.parseYear(value) == nil)
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
        #expect(TitleImportCSVParser.parseRuntime(value, locale: Locale(identifier: "en")) == expected)
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

    @Test("Final import preserves successes and rolls back failures")
    @MainActor
    func importsPartialResults() async throws {
        let container = PersistenceController.createTestingContainer()
        let writer = container.newBackgroundContext()
        let duplicate = MediaIdentity(type: .movie, tmdbID: 2)
        try await container.viewContext.perform {
            _ = Movie(context: container.viewContext, id: duplicate.tmdbID, title: "Existing")
            try container.viewContext.save()
        }
        let importer = TitleImportFinalImporter(
            provider: MockTitleImportMediaProvider(failingIDs: [3]),
            writerContext: writer,
            batchSize: 2
        )

        let result = await importer.importMedia(
            identities: [
                MediaIdentity(type: .movie, tmdbID: 1),
                duplicate,
                MediaIdentity(type: .movie, tmdbID: 3),
            ],
            libraryLimit: nil
        ) { _ in }

        #expect(result.importedCount == 1)
        #expect(result.duplicateCount == 1)
        #expect(result.failedIdentities == [MediaIdentity(type: .movie, tmdbID: 3)])
        let verificationContext = container.newBackgroundContext()
        let storedIDs = try await verificationContext.perform {
            try verificationContext.fetch(Media.fetchRequest()).map { $0.tmdbID }
        }
        #expect(Set(storedIDs) == [1, 2])
    }

    @Test("Final import saves writer context in bounded batches")
    @MainActor
    func savesBatches() async {
        let container = PersistenceController.createTestingContainer()
        let writer = container.newBackgroundContext()
        let saveCounter = LockedCounter()
        let token = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: writer,
            queue: nil
        ) { _ in
            saveCounter.increment()
        }
        defer { NotificationCenter.default.removeObserver(token) }
        let importer = TitleImportFinalImporter(
            provider: MockTitleImportMediaProvider(),
            writerContext: writer,
            batchSize: 2
        )

        let result = await importer.importMedia(
            identities: (1...3).map { MediaIdentity(type: .movie, tmdbID: $0) },
            libraryLimit: nil
        ) { _ in }

        #expect(result.importedCount == 3)
        #expect(saveCounter.value == 2)
    }

    @Test("Final import stops at the free library limit")
    @MainActor
    func enforcesFinalLibraryLimit() async throws {
        let container = PersistenceController.createTestingContainer()
        try await container.viewContext.perform {
            for id in 1...24 {
                _ = Movie(context: container.viewContext, id: id, title: "Existing \(id)")
            }
            try container.viewContext.save()
        }
        let importer = TitleImportFinalImporter(
            provider: MockTitleImportMediaProvider(),
            writerContext: container.newBackgroundContext(),
            batchSize: 10
        )
        let identities = [
            MediaIdentity(type: .movie, tmdbID: 25),
            MediaIdentity(type: .movie, tmdbID: 26),
        ]

        let result = await importer.importMedia(identities: identities, libraryLimit: 25) { _ in }

        #expect(result.importedCount == 1)
        #expect(result.remainingIdentities == [identities[1]])
    }

    @Test("Final import cancellation reports remaining identities")
    @MainActor
    func cancelsFinalImport() async throws {
        let container = PersistenceController.createTestingContainer()
        let importer = TitleImportFinalImporter(
            provider: MockTitleImportMediaProvider(delay: .seconds(1)),
            writerContext: container.newBackgroundContext()
        )
        let identities = (1...3).map { MediaIdentity(type: .movie, tmdbID: $0) }
        let task = Task {
            await importer.importMedia(identities: identities, libraryLimit: nil) { _ in }
        }

        try await Task.sleep(for: .milliseconds(20))
        task.cancel()
        let result = await task.value

        #expect(result.importedCount == 0)
        #expect(result.failedCount == 0)
        #expect(result.remainingIdentities == identities)
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

private struct MockTitleImportMediaProvider: TitleImportMediaProviding {
    let failingIDs: Set<Int>
    let delay: Duration?

    init(failingIDs: Set<Int> = [], delay: Duration? = nil) {
        self.failingIDs = failingIDs
        self.delay = delay
    }

    func titleImportMedia(for identity: MediaIdentity, context: NSManagedObjectContext) async throws {
        if let delay {
            try await Task.sleep(for: delay)
        }
        try await context.perform {
            switch identity.type {
            case .movie:
                _ = Movie(context: context, id: identity.tmdbID, title: "Imported")
            case .show:
                _ = Show(context: context, id: identity.tmdbID, title: "Imported")
            }
            if failingIDs.contains(identity.tmdbID) {
                throw MockImportError.failed
            }
        }
    }

    private enum MockImportError: Error {
        case failed
    }
}

private final class LockedCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0

    var value: Int {
        lock.withLock { count }
    }

    func increment() {
        lock.withLock { count += 1 }
    }
}
