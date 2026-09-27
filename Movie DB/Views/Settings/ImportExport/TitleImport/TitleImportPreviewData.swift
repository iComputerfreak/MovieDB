// Copyright © 2026 Jonas Frey. All rights reserved.

#if DEBUG
import Foundation

@MainActor
enum TitleImportPreviewData {
    static let sourceRows = [
        TitleImportSourceRow(
            id: 2,
            title: "The Matrix",
            year: 1999,
            directors: ["Lana Wachowski", "Lilly Wachowski"],
            runtimeMinutes: 136,
            mediaType: .movie
        ),
        TitleImportSourceRow(
            id: 3,
            title: "Dark",
            year: 2017,
            directors: ["Baran bo Odar"],
            runtimeMinutes: 60,
            mediaType: .show
        ),
        TitleImportSourceRow(
            id: 4,
            title: "Unknown Film",
            year: nil,
            directors: [],
            runtimeMinutes: nil,
            mediaType: nil
        ),
    ]

    static let preflight = TitleImportPreflight(
        rows: sourceRows,
        delimiter: ";",
        allHeaders: [
            "Titel",
            "Jahr",
            "Regie",
            "Laufzeit",
            "Typ",
            "Bewertung",
            "Notizen"
        ],
        headerMappings: [
            .title: "Titel",
            .year: "Jahr",
            .director: "Regie",
            .runtime: "Laufzeit",
            .mediaType: "Typ",
        ],
        ignoredHeaders: ["Bewertung", "Notizen"],
        malformedRowCount: 2
    )

    static let acceptedItem = TitleImportReviewItem(
        id: 2,
        source: sourceRows[0],
        candidate: TitleImportCandidate(
            identity: MediaIdentity(type: .movie, tmdbID: 603),
            title: "The Matrix",
            originalTitle: "The Matrix",
            year: 1999,
            imagePath: nil,
            popularity: 90,
            alternativeTitles: [],
            directors: ["Lana Wachowski", "Lilly Wachowski"],
            runtimeMinutes: 136
        ),
        status: .accepted,
        reason: Strings.TitleImport.Match.accepted,
        evidence: TitleImportMatchEvidence(
            titleMatch: true,
            yearMatch: true,
            directorMatch: true,
            runtimeMatch: true,
            mediaTypeMatch: true
        ),
        isIncluded: true
    )

    static let reviewItems = [
        acceptedItem,
        TitleImportReviewItem(
            id: 3,
            source: sourceRows[1],
            candidate: TitleImportCandidate(
                identity: MediaIdentity(type: .show, tmdbID: 70523),
                title: "Dark",
                originalTitle: "Dark",
                year: 2017,
                imagePath: nil,
                popularity: 70,
                alternativeTitles: [],
                directors: ["Baran bo Odar"],
                runtimeMinutes: 60
            ),
            status: .ambiguous,
            reason: Strings.TitleImport.Match.ambiguous,
            evidence: TitleImportMatchEvidence(titleMatch: true, yearMatch: true),
            isIncluded: false
        ),
        TitleImportReviewItem(
            id: 4,
            source: sourceRows[2],
            candidate: nil,
            status: .noMatch,
            reason: Strings.TitleImport.Match.noResults,
            evidence: TitleImportMatchEvidence(),
            isIncluded: false
        ),
    ]

    static func workflow(stage: TitleImportWorkflow.Stage = .review) -> TitleImportWorkflow {
        let workflow = TitleImportWorkflow(fileURL: URL(fileURLWithPath: "/tmp/title-import-preview.csv"))
        workflow.stage = stage
        workflow.preflight = preflight
        workflow.reviewItems = reviewItems
        workflow.processedCount = 2
        return workflow
    }
}
#endif
