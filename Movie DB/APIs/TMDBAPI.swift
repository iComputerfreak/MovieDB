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
    
    /// The ISO-639-1 language code
    var language: String = "de"
    var region: String = "DE"
    var locale: String {
        return "\(language)-\(region)"
    }
    
    init() {
        
    }
    
    /*func getMovieData() -> TMDBMovieData {
        
    }*/
    
    func searchResults(for query: String) {
        print("Starting Search")
        SearchMDB.movie(query: query, language: locale, page: 1, includeAdult: true, year: nil, primaryReleaseYear: nil) {
            data, movies in
            print(String(describing: movies?[0].title))
            print(String(describing: movies?[0].overview))
            print("Success")
        }
        print("Done")
    }
    
    func searchMedia(_ name: String, includeAdult: Bool = true, completion: @escaping ([TMDBSearchResult]?) -> Void) {
        let searchURL = "https://api.themoviedb.org/3/search/multi"
        let parameters: [String: Any?] = [
            "api_key": JFLiterals.apiKey.rawValue,
            "language": locale,
            "query": name,
            "include_adult": includeAdult,
            "region": region
        ]
        JFUtils.getRequest(searchURL, parameters: parameters) { (data) in
            guard let data = data else {
                return
            }
            
            let result = try? JSONDecoder().decode(SearchResult.self, from: data)
            completion(result?.results)
        }
    }
    
}
