// Copyright © 2026 Jonas Frey. All rights reserved.

import CoreData

protocol TitleImportMediaProviding: Sendable {
    func titleImportMedia(for identity: MediaIdentity, context: NSManagedObjectContext) async throws
}

extension TMDBAPI: TitleImportMediaProviding {
    func titleImportMedia(for identity: MediaIdentity, context: NSManagedObjectContext) async throws {
        _ = try await media(
            for: identity.tmdbID,
            type: identity.type,
            context: context,
            loadImages: false
        )
    }
}
