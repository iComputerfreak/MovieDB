//
//  UITestingUtils.swift
//  Movie DBUITests
//
//  Created by Jonas Frey on 26.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
@testable import Movie_DB

struct MediaSample {
    let type: MediaType
    let tmdbID: Int
    
    init(_ type: MediaType, _ tmdbID: Int) {
        self.type = type
        self.tmdbID = tmdbID
    }
}

class UITestingUtils {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func populateTenSampleMedias(in context: NSManagedObjectContext? = nil) async throws {
        let context = context ?? self.context
        let samples: [MediaSample] = [
            MediaSample(.movie, 284052), // Doctor Strange
            MediaSample(.movie, 634649), // Spider-Man: No Way Home
            MediaSample(.movie, 450465), // Glass
            MediaSample(.movie, 567609), // Ready or Not
            MediaSample(.movie, 602734), // Spiral: From the Book of Saw
            MediaSample(.show, 97175), // Fate: The Winx Saga
            MediaSample(.show, 1413), // American Horror Story
            MediaSample(.show, 58811), // Helix
            MediaSample(.show, 61550), // Marvel's Agent Carter
            MediaSample(.show, 73375), // Tom Clancy's Jack Ryan
        ]
        try await populateSamples(samples, in: context)
    }

    func populateTwoSampleMedias(in context: NSManagedObjectContext? = nil) async throws {
        let context = context ?? self.context
        let samples: [MediaSample] = [
            MediaSample(.movie, 284052), // Doctor Strange
            MediaSample(.show, 58811), // Helix
        ]
        try await populateSamples(samples, in: context)
    }

    func populateSamples(_ samples: [MediaSample], in context: NSManagedObjectContext) async throws {
        for sample in samples {
            _ = try await TMDBAPI.shared.media(for: sample.tmdbID, type: sample.type, context: context)
        }
    }
}
