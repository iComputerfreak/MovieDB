//
//  Deduplicator.swift
//  Movie DB
//
//  Created by Jonas Frey on 21.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

// TODO: Put into library, add min and max, maybe use this syntax in future: https://forums.swift.org/t/map-sorting/21421
extension Sequence {
    func sorted(by keyPath: KeyPath<Element, (some Comparable)?>) -> [Element] {
        sorted { a, b in
            // If value1 is nil, we sort it before value2 => return true
            guard let value1 = a[keyPath: keyPath] else {
                return true
            }
            // If value2 is nil, we sort it before value1 => return false
            guard let value2 = b[keyPath: keyPath] else {
                return false
            }
            return value1 < value2
        }
    }
}

class Deduplicator {
    init() {}
    
    /// Deduplicate Core Data entities by processing the given `NSManagedObjectID`s.
    ///
    /// All peers should eventually reach the same result with no coordination or communication.
    func deduplicateAndWait(_ entity: DeduplicationEntity, changedObjectIDs: [NSManagedObjectID]) {
        // Make any store changes on a background context
        let taskContext = PersistenceController.shared.newBackgroundContext()
        
        // Use performAndWait because each step relies on the sequence.
        // Because historyQueue (our caller) runs in the background, waiting won’t block the main queue.
        taskContext.performAndWait {
            changedObjectIDs.forEach { objectID in
                deduplicate(entity, changedObjectID: objectID, performingContext: taskContext)
            }
            // Save the background context to trigger a notification and merge the result into the viewContext.
            PersistenceController.saveContext(taskContext)
        }
    }
    
    // swiftlint:disable:next function_body_length
    private func deduplicate(
        _ entity: DeduplicationEntity,
        changedObjectID: NSManagedObjectID,
        performingContext: NSManagedObjectContext
    ) {
        let object = performingContext.object(with: changedObjectID)
        
        /// Cast the object to the generic type and return it on success
        func castObject<T>(as: T.Type = T.self) -> T {
            guard let object = object as? T else {
                fatalError("###\(#function): Failed to retrieve object for objectID: \(object.objectID)")
            }
            return object
        }
        
        // MARK: Decide how to select the winner
        
        // Make the function call a bit shorter by overloading the function locally
        func deduplicateObject<Entity: NSManagedObject>(
            _ object: Entity,
            chooseWinner: ([Entity]) -> Entity = { $0.first! },
            uniquePropertyName propertyName: String,
            uniquePropertyValue propertyValue: some CVarArg
        ) {
            self.deduplicateObject(
                object,
                entity: entity,
                chooseWinner: chooseWinner,
                uniquePropertyName: propertyName,
                uniquePropertyValue: propertyValue,
                performingContext: performingContext
            )
        }
        
        switch entity {
        case .media:
            let media: Media = castObject()
            deduplicateObject(
                media,
                // Use the media with the newest modification date
                chooseWinner: { $0.sorted(by: \.modificationDate).last! },
                uniquePropertyName: "id",
                uniquePropertyValue: media.id!.uuidString
            )
        case .tag:
            let tag: Tag = castObject()
            deduplicateObject(
                tag,
                // Use the first tag with a non-empty name
                chooseWinner: { $0.first(where: { !$0.name.isEmpty }) ?? $0.first! },
                uniquePropertyName: "id",
                uniquePropertyValue: tag.id.uuidString
            )
        case .genre:
            let genre: Genre = castObject()
            deduplicateObject(
                genre,
                // Use the first genre with a non-empty name
                chooseWinner: { $0.first(where: { !$0.name.isEmpty }) ?? $0.first! },
                uniquePropertyName: "id",
                uniquePropertyValue: genre.id
            )
        case .userMediaList:
            let list: UserMediaList = castObject()
            deduplicateObject(
                list,
                // Choose the list with the most objects
                chooseWinner: { $0.sorted(by: \UserMediaList.medias.count).last! },
                uniquePropertyName: "id",
                uniquePropertyValue: list.id.uuidString
            )
        case .dynamicMediaList:
            let list: DynamicMediaList = castObject()
            deduplicateObject(
                list,
                // Use the first list with a non-empty name
                chooseWinner: { $0.first(where: { !$0.name.isEmpty }) ?? $0.first! },
                uniquePropertyName: "id",
                uniquePropertyValue: list.id.uuidString
            )
        case .filterSetting:
            let filterSetting: FilterSetting = castObject()
            deduplicateObject(
                filterSetting,
                // Does not matter
                chooseWinner: { $0.first! },
                uniquePropertyName: "id",
                uniquePropertyValue: filterSetting.id!.uuidString
            )
        case .productionCompany:
            let company: ProductionCompany = castObject()
            deduplicateObject(
                company,
                // Use the first company with a non-empty name
                chooseWinner: { $0.first(where: { !$0.name.isEmpty }) ?? $0.first! },
                uniquePropertyName: "id",
                uniquePropertyValue: company.id
            )
        case .season:
            let season: Season = castObject()
            deduplicateObject(
                season,
                // Use the first season with a non-empty name
                chooseWinner: { $0.first(where: { !$0.name.isEmpty }) ?? $0.first! },
                uniquePropertyName: "id",
                uniquePropertyValue: season.id
            )
        case .video:
            let video: Video = castObject()
            deduplicateObject(
                video,
                // Use the first video with a non-empty name
                chooseWinner: { $0.first(where: { !$0.name.isEmpty }) ?? $0.first! },
                uniquePropertyName: "key",
                uniquePropertyValue: video.key
            )
        }
    }
    
    /// Deduplicates the given object instance using the given winner criteria
    /// - Parameters:
    ///   - object: The `NSManagedObject` instance to deduplicate
    ///   - entity: The `DeduplicationEntity` of the object
    ///   - chooseWinner: A closure that determines the index of the winner instance in a given list of duplicates
    ///   - propertyName: The name of the property to use for detecting duplicates.
    ///   - propertyValue: The value of the property for the given object.
    ///   - performingContext: The `NSManagedObjectContext` in which we are currently performing.
    private func deduplicateObject<Entity: NSManagedObject>( // swiftlint:disable:this function_parameter_count
        _ object: Entity,
        entity: DeduplicationEntity,
        chooseWinner: ([Entity]) -> Entity = { $0.first! },
        uniquePropertyName propertyName: String,
        uniquePropertyValue propertyValue: some CVarArg,
        performingContext: NSManagedObjectContext
    ) {
        guard entity.modelType == Entity.self else {
            // We crash here since it does not make sense to continue. We will crash in the switch statement below anyways
            fatalError("\(#function) called with mismatching object of type \(Entity.self) " +
                       "and entity parameter of type \(entity.modelType).")
        }
        
        // Fetch all objects with matching properties, sorted by the given keyPath
        let fetchRequest = NSFetchRequest<Entity>(entityName: Entity.entity().name!)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", propertyName, propertyValue)
        
        // Return if there are no duplicates.
        guard
            var duplicates = try? performingContext.fetch(fetchRequest),
            duplicates.count > 1
        else {
            return
        }
        
        print(
            "###\(#function): Deduplicating objects of type \(Entity.self) on property " +
            "\(propertyName) = \(propertyValue), count: \(duplicates.count)"
        )
        
        // Remove the winner object from the duplicates
        assert(
            Set(duplicates.map(\.objectID)).count == duplicates.count,
            "There are duplicates with identical objectIDs! The below selection algorithm will not work."
        )
        let winner = chooseWinner(duplicates)
        guard let winnerIndex = duplicates.firstIndex(where: { $0.objectID == winner.objectID }) else {
            print("###\(#function): The selected winner is not part of the provided duplicates.")
            return
        }
        duplicates.remove(at: winnerIndex)
        
        // Remove the other candidates (we need to split up into different functions here)
        // swiftlint:disable force_cast
        switch entity {
        case .media:
            remove(
                duplicatedMedias: duplicates as! [Media],
                winner: winner as! Media,
                performingContext: performingContext
            )
        case .tag:
            remove(
                duplicatedTags: duplicates as! [Tag],
                winner: winner as! Tag,
                performingContext: performingContext
            )
        case .genre:
            remove(
                duplicatedGenres: duplicates as! [Genre],
                winner: winner as! Genre,
                performingContext: performingContext
            )
        case .userMediaList:
            remove(
                duplicatedUserMediaLists: duplicates as! [UserMediaList],
                winner: winner as! UserMediaList,
                performingContext: performingContext
            )
        case .dynamicMediaList:
            remove(
                duplicatedDynamicMediaLists: duplicates as! [DynamicMediaList],
                winner: winner as! DynamicMediaList,
                performingContext: performingContext
            )
        case .filterSetting:
            remove(
                duplicatedFilterSettings: duplicates as! [FilterSetting],
                winner: winner as! FilterSetting,
                performingContext: performingContext
            )
        case .productionCompany:
            remove(
                duplicatedProductionCompanies: duplicates as! [ProductionCompany],
                winner: winner as! ProductionCompany,
                performingContext: performingContext
            )
        case .season:
            remove(
                duplicatedSeasons: duplicates as! [Season],
                winner: winner as! Season,
                performingContext: performingContext
            )
        case .video:
            remove(
                duplicatedVideos: duplicates as! [Video],
                winner: winner as! Video,
                performingContext: performingContext
            )
        }
        // swiftlint:enable force_cast
    }
}

// MARK: - Duplicate Removal

extension Deduplicator {
    /// Removes the given duplicate `Media` objects
    /// - Parameters:
    ///   - duplicatedMedias: The list of medias to remove
    ///   - winner: The winner media that can be used as a replacement
    ///   - performingContext: The `NSManagedObjectContext` we are currently performing in
    private func remove(duplicatedMedias: [Media], winner: Media, performingContext: NSManagedObjectContext) {
        duplicatedMedias.forEach { media in
            defer { performingContext.delete(media) }
            
            // TODO: Should we merge other properties? (notes, rating, watched, isFavorite, ...)
            
            print("###\(#function): Removing deduplicated Media")
            exchange(media, with: winner, in: \.medias, on: \.userLists)
            exchange(media, with: winner, in: \.medias, on: \.productionCompanies)
            exchange(media, with: winner, in: \.medias, on: \.genres)
            exchange(media, with: winner, in: \.medias, on: \.tags)
            
            // Media.videos and Show.seasons will be automatically deleted by their cascading deletion rules
            
            if
                let show = media as? Show,
                let winnerShow = winner as? Show
            {
                exchange(show, with: winnerShow, in: \.shows, on: \.networks)
            }
        }
    }
    
    private func remove(duplicatedTags: [Tag], winner: Tag, performingContext: NSManagedObjectContext) {
        duplicatedTags.forEach { tag in
            defer { performingContext.delete(tag) }
            
            print("###\(#function): Removing deduplicated Tag")
            exchange(tag, with: winner, in: \.tags, on: \.medias)
            exchange(tag, with: winner, in: \.tags, on: \.filterSettings)
        }
    }
    
    private func remove(duplicatedGenres: [Genre], winner: Genre, performingContext: NSManagedObjectContext) {
        duplicatedGenres.forEach { genre in
            defer { performingContext.delete(genre) }
            
            print("###\(#function): Removing deduplicated Genre")
            exchange(genre, with: winner, in: \.genres, on: \.filterSettings)
            exchange(genre, with: winner, in: \.genres, on: \.medias)
        }
    }
    
    private func remove(
        duplicatedUserMediaLists: [UserMediaList],
        winner: UserMediaList,
        performingContext: NSManagedObjectContext
    ) {
        duplicatedUserMediaLists.forEach { list in
            defer { performingContext.delete(list) }
            
            print("###\(#function): Removing deduplicated UserMediaList")
            exchange(list, with: winner, in: \.userLists, on: \.medias)
        }
    }
    
    private func remove(
        duplicatedDynamicMediaLists: [DynamicMediaList],
        winner: DynamicMediaList,
        performingContext: NSManagedObjectContext
    ) {
        duplicatedDynamicMediaLists.forEach { list in
            defer { performingContext.delete(list) }
            
            print("###\(#function): Removing deduplicated DynamicMediaList")
            // DynamicMediaList.filterSetting will be automatically deleted by their cascading deletion rule
        }
    }
    
    private func remove(duplicatedFilterSettings: [FilterSetting], winner: FilterSetting, performingContext: NSManagedObjectContext) {
        duplicatedFilterSettings.forEach { filterSetting in
            defer { performingContext.delete(filterSetting) }
            
            print("###\(#function): Removing deduplicated FilterSetting")
            exchange(filterSetting, with: winner, in: \.filterSettings, on: \.genres)
            exchange(filterSetting, with: winner, in: \.filterSettings, on: \.tags)
            
            // We need to exchange the duplicate on the DynamicMediaLists too
            filterSetting.mediaList?.filterSetting = winner
        }
    }
    
    private func remove(duplicatedProductionCompanies: [ProductionCompany], winner: ProductionCompany, performingContext: NSManagedObjectContext) {
        duplicatedProductionCompanies.forEach { productionCompany in
            defer { performingContext.delete(productionCompany) }
            
            print("###\(#function): Removing deduplicated ProductionCompany")
            exchange(productionCompany, with: winner, in: \.productionCompanies, on: \.medias)
            exchange(productionCompany, with: winner, in: \.productionCompanies, on: \.shows)
        }
    }
    
    private func remove(duplicatedSeasons: [Season], winner: Season, performingContext: NSManagedObjectContext) {
        duplicatedSeasons.forEach { season in
            defer { performingContext.delete(season) }
            
            print("###\(#function): Removing deduplicated Season")
            if let show = season.show {
                show.seasons.remove(season)
                show.seasons.insert(winner)
            }
        }
    }
    
    private func remove(duplicatedVideos: [Video], winner: Video, performingContext: NSManagedObjectContext) {
        duplicatedVideos.forEach { video in
            defer { performingContext.delete(video) }
            
            print("###\(#function): Removing deduplicated Video")
            if let media = video.media {
                media.videos.remove(video)
                media.videos.insert(winner)
            }
        }
    }
    
    /// Exchanges the given duplicate instance with the winner instance.
    /// The instance is exchanged in all sets that are located at the `referenceKeyPath` under the `propertyKeyPath`
    ///
    ///     let duplicateTag = Tag(...)
    ///     let winnerTag = Tag(...)
    ///
    ///     // Go through all medias associated with the duplicate tag (\.medias)
    ///     // and replace the duplicate tag in the tags of that media (\.tags)
    ///     exchange(duplicateTag, with: winnerTag, in: \.tags, on: \.medias)
    ///
    ///     // After execution, all medias in duplicateTag.medias contain the winnerTag,
    ///     // instead of the duplicateTag
    ///
    /// - Parameters:
    ///   - duplicate: The duplicate object
    ///   - winner: The winner object
    ///   - referenceKeyPath: A reference to a Set of objects of the same type as duplicate and winner.
    ///   - propertyKeyPath: A reference to a Set of objects of the same type as the root of the `referenceKeyPath`.
    private func exchange<T, V>(
        _ duplicate: T,
        with winner: T,
        in referenceKeyPath: ReferenceWritableKeyPath<V, Set<T>>,
        on propertyKeyPath: KeyPath<T, Set<V>>
    ) {
        // For each item in the given list, remove the duplicate and add the winner
        duplicate[keyPath: propertyKeyPath].forEach { item in
            item[keyPath: referenceKeyPath].remove(duplicate)
            item[keyPath: referenceKeyPath].insert(winner)
        }
    }
}
