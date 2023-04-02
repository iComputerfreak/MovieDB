//
//  PlaceholderData.swift
//  Movie DB
//
//  Created by Jonas Frey on 12.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import os.log
import UIKit

// swiftlint:disable function_body_length type_body_length
class PlaceholderData {
    static let preview: PlaceholderData = .init(context: PersistenceController.previewContext)
    
    static let api = TMDBAPI.shared
    
    let context: NSManagedObjectContext
    
    var medias: [Media] = []
    
    let staticMovie: Movie
    let staticShow: Show
    let staticProblemShow: Show
    
    var fskRatings: [ParentalRating] {
        [
            Self.fskRating(0, context: context),
            Self.fskRating(6, context: context),
            Self.fskRating(12, context: context),
            Self.fskRating(16, context: context),
            Self.fskRating(18, context: context),
        ]
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.staticMovie = Self.createStaticMovie(in: context)
        self.staticShow = Self.createStaticShow(in: context)
        self.staticProblemShow = Self.createStaticProblemShow(in: context)
    }
    
    func populateSamples() {
        Task(priority: .userInitiated) {
            do {
                // MARK: Matrix
                medias.append(try await createMovie(
                    603,
                    personalRating: .twoAndAHalfStars,
                    tags: ["Future", "Conspiracy", "Dark"],
                    notes: "",
                    watched: .watched,
                    watchAgain: false
                ))
                
                // MARK: The Blacklist
                medias.append(try await createShow(
                    46952,
                    personalRating: .fiveStars,
                    tags: ["Conspiracy", "Crime", "Gangsters", "Heist", "Highly Talented", "Prison", "Terrorist"],
                    notes: "A masterpiece!",
                    watched: .season(9),
                    watchAgain: true
                ))
                
                // MARK: Vikings (Missing information)
                medias.append(try await createShow(
                    44217, personalRating: .threeStars, tags: [], notes: "", watched: nil, watchAgain: false
                ))
            } catch {
                Logger.preview.error("\(error)")
            }
        }
    }
        
    private static func fskRating(_ age: Int, context: NSManagedObjectContext) -> ParentalRating {
        let color = Utils.parentalRatingColor(for: "DE", label: "\(age)", in: context)
        return ParentalRating(context: context, countryCode: "DE", label: "\(age)", color: color)
    }
    
    func mapTags(_ tagNames: [String]) -> Set<Tag> {
        Self.mapTags(tagNames, in: self.context)
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
    
    func createMovie(
        _ tmdbID: Int,
        personalRating: StarRating = .noRating,
        tags: [String] = [],
        notes: String = "",
        watched: MovieWatchState? = nil,
        watchAgain: Bool? = nil
    ) async throws -> Movie {
        let movie = try await createMedia(
            type: .movie,
            tmdbID: tmdbID,
            personalRating: personalRating,
            tags: tags,
            notes: notes,
            watchAgain: watchAgain
        ) as! Movie // swiftlint:disable:this force_cast
        movie.watched = watched
        return movie
    }
    
    func createShow(
        _ tmdbID: Int,
        personalRating: StarRating = .noRating,
        tags: [String] = [],
        notes: String = "",
        watched: ShowWatchState? = nil,
        watchAgain: Bool? = nil
    ) async throws -> Show {
        let show = try await createMedia(
            type: .movie,
            tmdbID: tmdbID,
            personalRating: personalRating,
            tags: tags,
            notes: notes,
            watchAgain: watchAgain
        ) as! Show // swiftlint:disable:this force_cast
        show.watched = watched
        return show
    }
    
    // swiftlint:disable:next function_parameter_count
    private func createMedia(
        type: MediaType,
        tmdbID: Int,
        personalRating: StarRating,
        tags: [String],
        notes: String,
        watchAgain: Bool?
    ) async throws -> Media {
        let media = try await Self.api.media(for: tmdbID, type: type, context: context)
        media.personalRating = personalRating
        media.tags = mapTags(tags)
        media.notes = notes
        media.watchAgain = watchAgain
        return media
    }
    
    func createStaticMovie() -> Movie {
        Self.createStaticMovie(in: self.context)
    }
    
    static func createStaticMovie(in context: NSManagedObjectContext) -> Movie {
        let tmdbData: TMDBData = load("Matrix.json", mediaType: .movie, into: context)
        let m = Movie(context: context, tmdbData: tmdbData)
        m.personalRating = .twoAndAHalfStars
        m.tags = Self.mapTags(["Future", "Conspiracy", "Dark"], in: context)
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
    
    func createStaticShow() -> Show {
        Self.createStaticShow(in: self.context)
    }
    
    static func createStaticShow(in context: NSManagedObjectContext) -> Show {
        let tmdbData: TMDBData = load("Blacklist.json", mediaType: .show, into: context)
        let s = Show(context: context, tmdbData: tmdbData)
        s.personalRating = .fiveStars
        s.tags = mapTags(["Gangsters", "Conspiracy", "Terrorist"], in: context)
        s.notes = "A masterpiece!"
        s.watched = .season(7)
        s.watchAgain = true
        s.parentalRating = fskRating(16, context: context)
        return s
    }
    
    func createStaticProblemShow() -> Show {
        Self.createStaticProblemShow(in: self.context)
    }
    
    static func createStaticProblemShow(in context: NSManagedObjectContext) -> Show {
        let show = createStaticShow(in: context)
        show.personalRating = .noRating
        show.tags = []
        show.notes = ""
        show.watchAgain = nil
        show.watched = nil
        return show
    }
    
    private static func load<T: Decodable>(
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
}
