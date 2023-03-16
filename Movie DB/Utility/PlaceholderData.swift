//
//  PlaceholderData.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import UIKit

// swiftlint:disable function_body_length
enum PlaceholderData {
    static let context = PersistenceController.previewContext
    
    static let allMedia: [Media] = fetchAll()
    static let movie: Movie = createMovie()
    static let show: Show = createShow()
    static let problemMovie: Movie = {
        let m = createMovie()
        m.watched = .watched
        m.personalRating = .noRating
        m.tags = []
        return m
    }()

    // A media with some missing information
    static let problemShow: Show = {
        let tmdbData: TMDBData = Self.load("Blacklist.json", mediaType: .show, into: context)
        let s = Show(context: context, tmdbData: tmdbData)
        s.notes = "A masterpiece!"
        s.watched = .season(7)
        s.parentalRating = fskRating(16, context: context)
        return s
    }()
    
    static func fskRatings(in context: NSManagedObjectContext) -> [ParentalRating] {
        [
            fskRating(0, context: context),
            fskRating(6, context: context),
            fskRating(12, context: context),
            fskRating(16, context: context),
            fskRating(18, context: context),
        ]
    }
        
    private static func fskRating(_ age: Int, context: NSManagedObjectContext) -> ParentalRating {
        let color = Utils.parentalRatingColor(for: "DE", label: "\(age)", in: context)
        return ParentalRating(context: context, countryCode: "DE", label: "\(age)", color: color)
    }
    
    static func mapTags(_ tagNames: [String], in context: NSManagedObjectContext) -> Set<Tag> {
        var tags: Set<Tag> = []
        for name in tagNames {
            let fetchRequest = Tag.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name = %@", name)
            if let tag = try? context.fetch(fetchRequest).first {
                // Use the existing tag
                tags.insert(tag)
            } else {
                // Create a new one
                tags.insert(Tag(name: name, context: context))
            }
        }
        return tags
    }
    
    static func createMovie(in context: NSManagedObjectContext = context) -> Movie {
        let tmdbData: TMDBData = Self.load("Matrix.json", mediaType: .movie, into: context)
        let m = Movie(context: context, tmdbData: tmdbData)
        m.personalRating = .twoAndAHalfStars
        m.tags = mapTags(["Future", "Conspiracy", "Dark"], in: context)
        m.notes = ""
        m.watched = .watched
        m.watchAgain = false
        m.parentalRating = fskRating(12, context: context)
        m.watchProviders = [
            .init(
                context: context,
                id: 0,
                type: .flatrate,
                name: "Netflix",
                imagePath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                priority: 100
            ),
            .init(
                context: context,
                id: 1,
                type: .ads,
                name: "RTL+",
                imagePath: "/3hI22hp7YDZXyrmXVqDGnVivNTI.jpg",
                priority: 5
            ),
            .init(
                context: context,
                id: 2,
                type: .flatrate,
                name: "Spectrum on Demand",
                imagePath: nil,
                priority: 20
            ),
            .init(
                context: context,
                id: 3,
                type: .buy,
                name: "Apple iTunes",
                imagePath: "/peURlLlr8jggOwK53fJ5wdQl05y.jpg",
                priority: 30
            ),
            .init(
                context: context,
                id: 4,
                type: .ads,
                name: "Peacock",
                imagePath: "/8VCV78prwd9QzZnEm0ReO6bERDa.jpg",
                priority: 9
            ),
            .init(
                context: context,
                id: 5,
                type: .flatrate,
                name: "Amazon Prime Video",
                imagePath: "/5NyLm42TmCqCMOZFvH4fcoSNKEW.jpg",
                priority: 30
            ),
            .init(
                context: context,
                id: 6,
                type: .flatrate,
                name: "Peacock Premium",
                imagePath: "/xTHltMrZPAJFLQ6qyCBjAnXSmZt.jpg",
                priority: 40
            ),
        ]
        return m
    }
    
    static func createShow(in context: NSManagedObjectContext = context) -> Show {
        let tmdbData: TMDBData = Self.load("Blacklist.json", mediaType: .show, into: context)
        let s = Show(context: context, tmdbData: tmdbData)
        s.personalRating = .fiveStars
        s.tags = mapTags(["Gangsters", "Conspiracy", "Terrorist"], in: context)
        s.notes = "A masterpiece!"
        s.watched = .season(7)
        s.watchAgain = true
        s.parentalRating = fskRating(16, context: context)
        return s
    }
    
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
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
    
    enum Lists {
        static let favorites = PredicateMediaList(
            name: "Favorites",
            iconName: "star.fill",
            predicate: NSPredicate(format: "%K == TRUE", Schema.Media.isFavorite.rawValue)
        )
        static let newSeasons = PredicateMediaList(
            name: Strings.Lists.defaultListNameNewSeasons,
            iconName: "sparkles.tv",
            predicate: NSCompoundPredicate(type: .and, subpredicates: [
                NSPredicate(format: "type = %@", MediaType.show.rawValue),
                ShowWatchState.showsWatchedAnyPredicate,
                NSPredicate(format: "lastSeasonWatched < numberOfSeasons"),
            ])
        )
    }
}
