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
    
    /// Creates a new `Movie` object.
    convenience init(context: NSManagedObjectContext, tmdbData: TMDBData) {
        self.init(context: context)
        self.initMedia(type: .movie, tmdbData: tmdbData)
    }
    
    override func initMedia(type: MediaType, tmdbData: TMDBData) {
        super.initMedia(type: type, tmdbData: tmdbData)
        setTMDBMovieData(tmdbData)
    }
    
    override func update(tmdbData: TMDBData) {
        super.update(tmdbData: tmdbData)
        setTMDBMovieData(tmdbData)
    }
    
    private func setTMDBMovieData(_ tmdbData: TMDBData) {
        managedObjectContext!.perform {
            // This is a movie, therefore the TMDBData needs to have movie specific data
            let movieData = tmdbData.movieData!
            self.releaseDate = movieData.releaseDate
            self.runtime = movieData.runtime
            self.budget = movieData.budget
            self.revenue = movieData.revenue
            self.tagline = movieData.tagline
            self.isAdult = movieData.isAdult
            self.imdbID = movieData.imdbID
        }
    }
    
    override func missingInformation() -> Set<MediaInformation> {
        var missing = super.missingInformation()
        if watched == nil {
            missing.insert(.watched)
        }
        return missing
    }

}
