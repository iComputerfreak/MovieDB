// Copyright © 2023 Jonas Frey. All rights reserved.

import CoreData
import Foundation

/// The data loaded when starting the app with the appropriate command line argument for doing app store screenshots through UI tests
struct AppStoreScreenshotData {
    let context: NSManagedObjectContext
    
    private enum TagName {
        case future
        case conspiracy
        case dark
        case violent
        case gangsters
        case terrorist
        case past
        case fantasy
        case comedy
        case timeTravel
        case space
    }

    private var tags: [TagName: Tag] = [:]
    private let languageCode: String
    
    /// Creates a provider that inserts localized sample data for App Store screenshots.
    /// - Parameter context: The context into which sample data is inserted.
    init(context: NSManagedObjectContext) {
        self.context = context
        self.languageCode = Locale.current.language.languageCode?.identifier ?? "en"

        let tagNames: [TagName: String]
        if languageCode == "fr" {
            tagNames = [
                .future: "Futur",
                .conspiracy: "Complot",
                .dark: "Sombre",
                .violent: "Violent",
                .gangsters: "Gangsters",
                .terrorist: "Terrorisme",
                .past: "Passé",
                .fantasy: "Fantastique",
                .comedy: "Comédie",
                .timeTravel: "Voyage dans le temps",
                .space: "Espace",
            ]
        } else {
            tagNames = [
                .future: "Future",
                .conspiracy: "Conspiracy",
                .dark: "Dark",
                .violent: "Violent",
                .gangsters: "Gangsters",
                .terrorist: "Terrorist",
                .past: "Past",
                .fantasy: "Fantasy",
                .comedy: "Comedy",
                .timeTravel: "Time Travel",
                .space: "Space",
            ]
        }

        // Create some tags
        self.tags = tagNames.mapValues { Tag(name: $0, context: context) }
    }
    
    // swiftlint:disable force_cast
    func prepareSampleData() async throws {
        let matrixNote = languageCode == "fr" ? "Un très bon film !" : "A pretty good movie!"
        let lokiNote = languageCode == "fr" ? "Vivement la prochaine saison !" : "Can't wait for another season!"

        // MARK: Create Movies and Shows
        let api = TMDBAPI.shared
        
        // MARK: Fetch medias
        // Matrix
        let matrix = try await api.media(for: 603, type: .movie, context: context) as! Movie
        let loki = try await api.media(for: 84958, type: .show, context: context) as! Show
        let expanse = try await api.media(for: 63639, type: .show, context: context) as! Show
        let drwho = try await api.media(for: 57243, type: .show, context: context) as! Show

        await context.perform {
            // MARK: Configure properties
            matrix.personalRating = .fourStars
            matrix.watched = .watched
            matrix.watchAgain = true
            matrix.watchDate = .now
            matrix.tags = getTags([.future, .conspiracy])
            matrix.notes = matrixNote
            
            loki.personalRating = .fiveStars
            loki.watched = .notWatched
            loki.watchAgain = nil
            loki.tags = getTags([.comedy])
            loki.notes = lokiNote
            loki.isOnWatchlist = true
            
            expanse.personalRating = .fourAndAHalfStars
            expanse.watched = .episode(season: 5, episode: 3)
            expanse.watchAgain = false
            expanse.watchDate = .now.addingTimeInterval(-12 * .day)
            expanse.tags = getTags([.future, .space])
            expanse.notes = ""
            expanse.isFavorite = true
            
            drwho.personalRating = .fiveStars
            drwho.watched = .season(12)
            drwho.watchAgain = true
            drwho.watchDate = .now.addingTimeInterval(-60 * .day)
            drwho.tags = getTags([.future, .timeTravel, .space])
            drwho.notes = ""
            drwho.isOnWatchlist = true
            drwho.isFavorite = true
        }
    }
    
    // swiftlint:enable force_cast
    
    private func getTags(_ tags: [TagName]) -> Set<Tag> {
        Set(tags.map { self.tags[$0]! })
    }
}
