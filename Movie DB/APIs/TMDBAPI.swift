//
//  TMDBAPI.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import TMDBWrapper

struct TMDBAPI {
    
    let apiKey = "e4304a9deeb9ed2d62eb61d7b9a2da71"
    /// The ISO-639-1 language code
    var locale: String = "de"
    
    init() {
        TMDBConfig.apikey = apiKey
    }
    
    /*func getMovieData() -> TMDBMovieData {
        
    }*/
    
    func searchResults(for query: String) {
        print("Starting Search")
        SearchMDB.movie(query: query, language: locale, page: 1, includeAdult: true, year: nil, primaryReleaseYear: nil) {
            data, movies in
            print(movies?[0].title)
            print(movies?[0].overview)
            print("Success")
        }
        print("Done")
    }
    
}

// MARK: - Return Structs
