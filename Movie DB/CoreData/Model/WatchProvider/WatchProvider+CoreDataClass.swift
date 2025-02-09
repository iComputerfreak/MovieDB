//
//  WatchProvider+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation
import os.log

@objc(WatchProvider)
public class WatchProvider: NSManagedObject {
    convenience init(
        context: NSManagedObjectContext,
        id: Int,
        type: ProviderType,
        name: String,
        imagePath: String?,
        priority: Int
    ) {
        self.init(context: context)
        self.id = id
        self.type = type
        self.name = name
        self.imagePath = imagePath
        self.priority = priority
    }
    
    convenience init(context: NSManagedObjectContext, dummy: WatchProviderDummy, type: WatchProvider.ProviderType) {
        self.init(
            context: context,
            id: dummy.id,
            type: type,
            name: dummy.name,
            imagePath: dummy.imagePath,
            priority: dummy.priority
        )
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Download the logo and store it as png data
        self.loadLogoImage()
    }
    
    override public func awakeFromFetch() {
        super.awakeFromFetch()
        self.loadLogoImage()
    }
    
    private var loadLogoTask: Task<Void, Never>?
    
    func loadLogoImage() {
        // !!!: Use lots of Task.isCancelled to make sure this media object still exists during execution,
        // !!!: otherwise accessing e.g. the unowned managedObjectContext property crashes the app

        // Start loading the thumbnail
        // Use a dedicated overall task to be able to cancel it
        self.loadLogoTask = Task { [managedObjectContext] in
            guard !Task.isCancelled else { return }

            // We need to access the imagePath on the managedObjectContext's thread
            await managedObjectContext?.perform {
                guard self.logoImage == nil else {
                    // Logo already present or no context, don't download again
                    return
                }
            }
            
            var providerID: WatchProvider.ID?
            var imagePath: String?
            
            guard !Task.isCancelled else { return }

            await managedObjectContext?.perform {
                providerID = self.id
                imagePath = self.imagePath
            }
            
            Task { [providerID, imagePath] in
                guard !Task.isCancelled, let providerID else { return }
                
                do {
                    let logoImage = try await TMDBImageService.watchProviderLogos.image(
                        for: imagePath,
                        downloadID: providerID
                    )
                    if !Task.isCancelled {
                        await managedObjectContext?.perform {
                            self.objectWillChange.send()
                            self.logoImage = logoImage
                        }
                    }
                } catch {
                    Logger.coreData.warning(
                        // swiftlint:disable:next line_length
                        "[\(self.name, privacy: .public)] Error (down-)loading thumbnail: \(error) (mediaID: \(self.id, privacy: .public))"
                    )
                }
            }
        }
    }
    
    static func fetchOrCreate(
        _ dummy: WatchProviderDummy,
        type: WatchProvider.ProviderType,
        in context: NSManagedObjectContext
    ) -> WatchProvider {
        let fetchRequest = Self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", Schema.WatchProvider.id.rawValue, dummy.id as NSNumber)
        fetchRequest.fetchLimit = 1
        if let result = try? context.fetch(fetchRequest).first {
            return result
        }
        
        // Create instead
        return WatchProvider(context: context, dummy: dummy, type: type)
    }
}
