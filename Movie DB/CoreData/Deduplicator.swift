//
//  Deduplicator.swift
//  Movie DB
//
//  Created by Jonas Frey on 21.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

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
        
        // TODO: Maybe we should do the winner selection in a closure instead of using a KeyPath to support more complex decisions?
        
        // Make the function call a bit shorter by overloading the function locally
        func deduplicateObject<T: NSManagedObject>(
            _ object: T,
            chosenBy keyPath: KeyPath<T, some Any>,
            ascending: Bool,
            uniquePropertyName propertyName: String,
            uniquePropertyValue propertyValue: some CVarArg
        ) {
            self.deduplicateObject(
                object,
                entity: entity,
                chosenBy: keyPath,
                ascending: ascending,
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
                chosenBy: \Media.modificationDate,
                ascending: false,
                uniquePropertyName: "id",
                uniquePropertyValue: media.id!.uuidString
            )
        case .tag:
            let tag: Tag = castObject()
            deduplicateObject(
                tag,
                chosenBy: \Tag.name,
                ascending: false,
                uniquePropertyName: "id",
                uniquePropertyValue: tag.id.uuidString
            )
        case .genre:
            let genre: Genre = castObject()
            deduplicateObject(
                genre,
                chosenBy: \Genre.name,
                ascending: false,
                uniquePropertyName: "id",
                uniquePropertyValue: genre.id
            )
        case .userMediaList:
            let list: UserMediaList = castObject()
            deduplicateObject(
                list,
                chosenBy: \UserMediaList.medias.count, // Choose the list with the most objects
                ascending: false,
                uniquePropertyName: "id",
                uniquePropertyValue: list.id.uuidString
            )
        case .dynamicMediaList:
            let list: DynamicMediaList = castObject()
            deduplicateObject(
                list,
                chosenBy: \DynamicMediaList.name,
                ascending: false,
                uniquePropertyName: "id",
                uniquePropertyValue: list.id.uuidString
            )
        case .filterSetting:
            let filterSetting: FilterSetting = castObject()
            deduplicateObject(
                filterSetting,
                chosenBy: \FilterSetting.tags.count, // TODO: I would prefer to use random here
                ascending: false,
                uniquePropertyName: "id",
                uniquePropertyValue: filterSetting.id!.uuidString
            )
        case .productionCompany:
            let company: ProductionCompany = castObject()
            deduplicateObject(
                company,
                chosenBy: \ProductionCompany.name,
                ascending: false,
                uniquePropertyName: "id",
                uniquePropertyValue: company.id
            )
        case .season:
            let season: Season = castObject()
            deduplicateObject(
                season,
                chosenBy: \Season.name,
                ascending: false,
                uniquePropertyName: "id",
                uniquePropertyValue: season.id
            )
        case .video:
            let video: Video = castObject()
            deduplicateObject(
                video,
                chosenBy: \Video.name,
                ascending: false,
                uniquePropertyName: "key",
                uniquePropertyValue: video.key
            )
        }
    }
    
    /// Deduplicates the given object instance using the given winner criteria
    /// - Parameters:
    ///   - object: The `NSManagedObject` instance to deduplicate
    ///   - entity: The `DeduplicationEntity` of the object
    ///   - keyPath: A `KeyPath` describing the property to use for selecting a winner between the duplicates. The duplicates will be sorted by this property.
    ///   - ascending: Whether the duplicates should be sorted by the given keyPath in an ascending order, before choosing the first object as the winner.
    ///   - propertyName: The name of the property to use for detecting duplicates.
    ///   - propertyValue: The value of the property for the given object.
    ///   - performingContext: The `NSManagedObjectContext` in which we are currently performing.
    private func deduplicateObject<T: NSManagedObject>( // swiftlint:disable:this function_parameter_count
        _ object: T,
        entity: DeduplicationEntity,
        chosenBy keyPath: KeyPath<T, some Any>,
        ascending: Bool,
        uniquePropertyName propertyName: String,
        uniquePropertyValue propertyValue: some CVarArg,
        performingContext: NSManagedObjectContext
    ) {
        guard entity.modelType == T.self else {
            // We crash here since it does not make sense to continue. We will crash in the switch statement below anyways
            fatalError("Error: deduplicate() called with mismatching object of type \(T.self) " +
                       "and entity parameter of type \(entity.modelType).")
        }
        
        // Fetch all objects with matching properties, sorted by the given keyPath
        let fetchRequest = NSFetchRequest<T>(entityName: T.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: keyPath, ascending: ascending)]
        fetchRequest.predicate = NSPredicate(format: "%K == %@", propertyName, propertyValue)
        
        // Return if there are no duplicates.
        guard
            var duplicates = try? performingContext.fetch(fetchRequest),
            duplicates.count > 1
        else {
            return
        }
        
        print(
            "###\(#function): Deduplicating objects of type \(T.self) on property " +
            "\(propertyName) = \(propertyValue), count: \(duplicates.count)"
        )
        
        // Pick the first object as the winner
        let winner = duplicates.first!
        duplicates.removeFirst()
        
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
            break
        case .userMediaList:
            break
        case .dynamicMediaList:
            break
        case .filterSetting:
            break
        case .productionCompany:
            break
        case .season:
            break
        case .video:
            break
        }
        // swiftlint:enable force_cast
    }
    
    /// Removes the given duplicate `Media` objects
    /// - Parameters:
    ///   - duplicatedMedias: The list of medias to remove
    ///   - winner: The winner media that can be used as a replacement
    ///   - performingContext: The `NSManagedObjectContext` we are currently performing in
    private func remove(duplicatedMedias: [Media], winner: Media, performingContext: NSManagedObjectContext) {
        duplicatedMedias.forEach { media in
            defer { performingContext.delete(media) }
            
            // TODO: Should we merge other properties? (notes, rating, watched, isFavorite, ...)
            
            print("###\(#function): Removing deduplicated medias")
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
    
    /// Removes the given duplicate `Tag` objects
    /// - Parameters:
    ///   - duplicatedTags: The list of tags to remove
    ///   - winner: The winner tag that can be used as a replacement
    ///   - performingContext: The `NSManagedObjectContext` we are currently performing in
    private func remove(duplicatedTags: [Tag], winner: Tag, performingContext: NSManagedObjectContext) {
        duplicatedTags.forEach { tag in
            defer { performingContext.delete(tag) }
            
            print("###\(#function): Removing deduplicated tags")
            exchange(tag, with: winner, in: \.tags, on: \.medias)
            exchange(tag, with: winner, in: \.tags, on: \.filterSettings)
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
