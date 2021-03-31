//
//  Persistence.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData

struct PersistenceController {
    
    let container: NSPersistentCloudKitContainer
    
    /// Creates and returns a new `NSManagedObjectContext` that can be used for creating temporary data (e.g., Seasons that are part of a `SearchResult`)
    var disposableContext: NSManagedObjectContext {
        // The disposable context is a new empty context without any data in it
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.name = "Disposable Context (\(Date()))"
        return context
    }
    
    private init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Movie DB")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Automatically merge changes done in other context of this container.
        // E.g. merge changes from a background context, as soon as that context saves
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.name = "View Context"
    }
    
    /// Saves the shared viewContext
    func saveContext () {
        print("========================")
        print("SAVING CORE DATA CONTEXT")
        print("========================")
        PersistenceController.saveContext(context: container.viewContext)
    }
    
    // MARK: - Static Properties and Functions
    
    static let shared = PersistenceController()
    
    static var viewContext: NSManagedObjectContext {
        return shared.container.viewContext
    }
    
    static var previewContext: NSManagedObjectContext {
        return preview.container.viewContext
    }
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample library
        let library = MediaLibrary(context: viewContext)
        
        // Create sample Tags
        var tags: [Tag] = []
        for name in ["Happy Ending", "Trashy", "Time Travel", "Immortality"] {
            tags.append(Tag(name: name, context: viewContext))
        }
        
        // Create sample TMDBData
        let decoder = JSONDecoder()
        
        let jsonMovieData = try! Data(contentsOf: Bundle.main.url(forResource: "TMDBMovie", withExtension: "json")!)
        decoder.userInfo = [.managedObjectContext: viewContext, .mediaType: MediaType.movie]
        let tmdbMovieData = try! decoder.decode(TMDBData.self, from: jsonMovieData)
        
        let jsonShowData = try! Data(contentsOf: Bundle.main.url(forResource: "TMDBShow", withExtension: "json")!)
        decoder.userInfo = [.managedObjectContext: viewContext, .mediaType: MediaType.show]
        let tmdbShowData = try! decoder.decode(TMDBData.self, from: jsonShowData)
        
        // Create Media objects
        let m = Movie(context: viewContext, tmdbData: tmdbMovieData)
        m.personalRating = .fourStars
        m.watched = true
        m.watchAgain = false
        m.tags = [tags[0], tags[1], tags[3]]
        m.notes = "Sample Note\nWith multiple\nlines."
        
        let s = Show(context: viewContext, tmdbData: tmdbShowData)
        s.personalRating = .oneAndAHalfStars
        s.lastWatched = .init(season: 3, episode: 5)
        s.watchAgain = nil
        s.tags = [tags[2], tags[0]]
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    // MARK: Saving
    
    /// Saves the shared viewContext
    static func saveContext(file: String = #file, line: Int = #line) {
        print("Saving shared viewContext from \(file):\(line)")
        shared.saveContext()
    }
    
    /// Saves the given context if it has been modified since the last save
    /// - Parameter context: The `NSManagedObjectContext` to save
    static func saveContext(context: NSManagedObjectContext, file: String = #file, line: Int = #line) {
        print("Trying to save context from \(file):\(line).")
        // Make sure we save on the correct thread to prevent race conditions
        // See: https://developer.apple.com/forums/thread/668299
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
}
