// Copyright © 2026 Jonas Frey. All rights reserved.

import CoreData

/// Creates a fully decoded media object for a resolved title-import identity.
protocol TitleImportMediaProviding: Sendable {
    /// Fetches and inserts one media object into the supplied context without eager image loading.
    /// - Parameters:
    ///   - identity: The TMDB identity to import.
    ///   - context: The disposable managed object context that should receive the decoded object graph.
    /// - Throws: A network, API, decoding, Core Data, or cancellation error when creation fails.
    func titleImportMedia(for identity: MediaIdentity, context: NSManagedObjectContext) async throws
}

extension TMDBAPI: TitleImportMediaProviding {
    /// Fetches and inserts one media object into the supplied context without eager image loading.
    /// - Parameters:
    ///   - identity: The TMDB identity to import.
    ///   - context: The disposable managed object context that should receive the decoded object graph.
    /// - Throws: A network, API, decoding, Core Data, or cancellation error when creation fails.
    func titleImportMedia(for identity: MediaIdentity, context: NSManagedObjectContext) async throws {
        _ = try await media(
            for: identity.tmdbID,
            type: identity.type,
            context: context,
            loadImages: false
        )
    }
}
