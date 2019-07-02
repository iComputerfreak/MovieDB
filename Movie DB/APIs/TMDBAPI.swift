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
    
    let apiKey: String
    /// The ISO-639-1 language code
    var language: String = "de"
    var region: String = "DE"
    var locale: String {
        return "\(language)-\(region)"
    }
    
    func getMedia<T: TMDBData>(by id: Int, type: MediaType, completion: @escaping (T?) -> Void) {
        let url = "https://api.themoviedb.org/3/\(type.rawValue)/\(id)"
        if id == 48891 {
            print("Break here")
        }
        JFUtils.getRequest(url, parameters: [
            "api_key": apiKey,
            "language": locale
        ]) { (data) in
            guard let data = data else {
                // On fail, call the completion with nil, so the caller knows, it failed
                print("JFUtils.getRequest returned nil")
                completion(nil)
                return
            }
            let result = try! JSONDecoder().decode(T.self, from: data)
            completion(result)
        }
    }
    
    // Convenience function
    func getMovie(by id: Int, completion: @escaping (TMDBMovieData?) -> Void) {
        getMedia(by: id, type: .movie, completion: completion)
    }
    
    // Convenience function
    func getShow(by id: Int, completion: @escaping (TMDBShowData?) -> Void) {
        getMedia(by: id, type: .show, completion: completion)
    }
    
    func searchMedia(_ name: String, includeAdult: Bool = true, completion: @escaping ([TMDBSearchResult]?) -> Void) {
        let searchURL = "https://api.themoviedb.org/3/search/multi"
        let parameters: [String: Any?] = [
            "api_key": apiKey,
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
