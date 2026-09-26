// Copyright © 2026 Jonas Frey. All rights reserved.

import CoreData
import Foundation

enum TitleImportDeduplicator {
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
