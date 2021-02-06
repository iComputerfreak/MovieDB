//
//  Movie+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Movie)
public class Movie: Media {
    
    // Sadly the only way to properly set up the init structure here is to duplicate the init code from Media for Show and Movie.
    // The clean way would be to have a convenience init(context:tmdbData:) in Show and Movie and call a convenience init(context:type:tmdbData:) in Media which calls super.init(context:)
    // This is not possible, since convenience initializers must call an initializer from the same class
    /// Creates a new `Movie` object.
    convenience init(context: NSManagedObjectContext, tmdbData: TMDBData) {
        self.init(context: context)
        super.initMedia(type: .movie, tmdbData: tmdbData)
        
        // This is a movie, therefore the TMDBData needs to have movie specific data
        let movieData = tmdbData.movieData!
        self.releaseDate = movieData.releaseDate
        // TODO: self.runtime = Int64(movieData.runtime)
        self.budget = movieData.budget
        self.revenue = movieData.revenue
        self.tagline = movieData.tagline
        self.isAdult = movieData.isAdult
        self.imdbID = movieData.imdbID
    }

}
