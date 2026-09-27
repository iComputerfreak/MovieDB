// Copyright © 2026 Jonas Frey. All rights reserved.

import CoreData
import Foundation

/// Detects candidates already in the library or repeated within the current source file.
enum TitleImportDeduplicator {
    /// Fetches every persisted media identity without materializing full managed objects.
    /// - Returns: The identities currently stored in the library.
    /// - Throws: A Core Data fetch error when existing identities cannot be read.
    static func existingIdentities() async throws -> Set<MediaIdentity> {
        let context = PersistenceController.shared.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<NSDictionary>(entityName: "Media")
            request.resultType = .dictionaryResultType
            request.propertiesToFetch = [Schema.Media.tmdbID.rawValue, Schema.Media.type.rawValue]
            return try context.fetch(request).reduce(into: Set<MediaIdentity>()) { identities, values in
                guard
                    let tmdbID = values[Schema.Media.tmdbID.rawValue] as? Int,
                    let rawType = values[Schema.Media.type.rawValue] as? String,
                    let type = MediaType(rawValue: rawType)
                else { return }
                identities.insert(MediaIdentity(type: type, tmdbID: tmdbID))
            }
        }
    }

    /// Marks review items as duplicates while preserving the first source-row owner of each identity.
    /// - Parameters:
    ///   - items: The review items in source-file order.
    ///   - existingIdentities: The identities already stored in the library.
    /// - Returns: Review items with duplicate status, provenance, reason, and inclusion state applied.
    static func apply(
        to items: [TitleImportReviewItem],
        existingIdentities: Set<MediaIdentity>
    ) -> [TitleImportReviewItem] {
        // Source order determines ownership: later rows resolving to the same identity become locked duplicates.
        var owners: [MediaIdentity: Int] = [:]
        return items.map { item in
            guard let identity = item.candidate?.identity else { return item }
            var item = item
            if existingIdentities.contains(identity) {
                item.status = .duplicate
                item.duplicateKind = .existingLibrary
                item.reason = Strings.TitleImport.Match.existingDuplicate
                item.isIncluded = false
            } else if let owner = owners[identity] {
                item.status = .duplicate
                item.duplicateKind = .sourceRow(owner)
                item.reason = Strings.TitleImport.Match.fileDuplicate(owner)
                item.isIncluded = false
            } else {
                owners[identity] = item.source.rowNumber
            }
            return item
        }
    }
}
