//
//  PlaceholderData.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData

enum PlaceholderData {
    static let context = PersistenceController.previewContext
    
    static let allMedia: [Media] = fetchAll()
    static let movie: Movie = {
        let tmdbData: TMDBData = Self.load("Matrix.json", mediaType: .movie, into: context)
        let m = Movie(context: context, tmdbData: tmdbData)
        m.personalRating = .twoAndAHalfStars
        m.tags = Set(["Future", "Conspiracy", "Dark"]
            .map { name in allTags.first(where: { $0.name == name })! })
        m.notes = ""
        m.watched = true
        m.watchAgain = false
        m.parentalRating = .fskAgeTwelve
        m.watchProviders = [
            .init(
                id: 0,
                type: .flatrate,
                name: "Netflix",
                imagePath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                priority: 100
            ),
            .init(
                id: 1,
                type: .ads,
                name: "RTL+",
                imagePath: "/3hI22hp7YDZXyrmXVqDGnVivNTI.jpg",
                priority: 5
            ),
            .init(
                id: 2,
                type: .flatrate,
                name: "Spectrum on Demand",
                imagePath: "/79mRAYq40lcYiXkQm6N7YErSSHd.jpg",
                priority: 20
            ),
            .init(
                id: 3,
                type: .buy,
                name: "Apple iTunes",
                imagePath: "/peURlLlr8jggOwK53fJ5wdQl05y.jpg",
                priority: 30
            ),
            .init(
                id: 4,
                type: .ads,
                name: "Peacock",
                imagePath: "/8VCV78prwd9QzZnEm0ReO6bERDa.jpg",
                priority: 9
            ),
            .init(
                id: 5,
                type: .flatrate,
                name: "Amazon Prime Video",
                imagePath: "/5NyLm42TmCqCMOZFvH4fcoSNKEW.jpg",
                priority: 30
            ),
            .init(
                id: 6,
                type: .flatrate,
                name: "Peacock Premium",
                imagePath: "/xTHltMrZPAJFLQ6qyCBjAnXSmZt.jpg",
                priority: 40
            )
        ]
        return m
    }()
    static let show: Show = {
        let tmdbData: TMDBData = Self.load("Blacklist.json", mediaType: .show, into: context)
        let s = Show(context: context, tmdbData: tmdbData)
        s.personalRating = .fiveStars
        s.tags = Set(["Gangsters", "Conspiracy", "Terrorist"]
            .map { name in allTags.first(where: { $0.name == name })! })
        s.notes = "A masterpiece!"
        s.lastWatched = .init(season: 7, episode: nil)
        s.watchAgain = true
        s.parentalRating = .fskAgeSixteen
        return s
    }()
    
    static let allTags: [Tag] = [
        Tag(name: "Future", context: context),
        Tag(name: "Conspiracy", context: context),
        Tag(name: "Dark", context: context),
        Tag(name: "Violent", context: context),
        Tag(name: "Gangsters", context: context),
        Tag(name: "Terrorist", context: context),
        Tag(name: "Past", context: context),
        Tag(name: "Fantasy", context: context)
    ]
    
    private static func fetchFirst<T: NSManagedObject>() -> T {
        fetchAll().first!
    }
    
    private static func fetchAll<T: NSManagedObject>() -> [T] {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: T.entity().name!)
        // Only used in Previews
        // swiftlint:disable:next force_try
        return try! context.fetch(fetchRequest)
    }
    
    static func load<T: Decodable>(
        _ filename: String,
        mediaType: MediaType? = nil,
        into context: NSManagedObjectContext,
        as type: T.Type = T.self
    ) -> T {
        let data: Data
        
        guard let bundle = Bundle(identifier: "de.JonasFrey.Movie-DB") else {
            fatalError("Unable to load bundle")
        }
        
        print(bundle)
                
        guard let file = bundle.url(forResource: "\(filename)", withExtension: nil) else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.userInfo[.managedObjectContext] = context
            decoder.userInfo[.mediaType] = mediaType
            return try decoder.decode(T.self, from: data)
        } catch let error {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
}
