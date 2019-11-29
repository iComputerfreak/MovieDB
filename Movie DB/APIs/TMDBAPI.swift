//
//  TMDBAPI.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

struct TMDBAPI {
    
    /// The base part of the TheMovieDB.org API URL
    private let baseURL = "https://api.themoviedb.org/3"
    
    let apiKey: String
    /// The ISO-639-1 language code
    var language: String = "de"
    var region: String = "DE"
    var locale: String {
        return "\(language)-\(region)"
    }
    
    // Returns a concrete subclass
    /// Fetches a subclass of `Media` from TheMovieDB.org for a given media ID and a given `MediaType`.
    /// - Parameters:
    ///   - id: The id of the media on TheMovieDB.org
    ///   - type: The type of media
    ///   - completion: The code to execute when the request is completed
    func getMedia(by id: Int, type: MediaType, completion: @escaping (TMDBData?) -> Void) {
        let url = "\(baseURL)/\(type.rawValue)/\(id)"
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
            do {
                if type == .movie {
                    completion(try JSONDecoder().decode(TMDBMovieData.self, from: data))
                } else {
                    completion(try JSONDecoder().decode(TMDBShowData.self, from: data))
                }
            } catch let e as DecodingError {
                print("Error decoding: \(e)")
            } catch {
                print("Other error")
            }
        }
    }
    
    /// Searches for a media with a given name on TheMovieDB.org.
    /// - Parameters:
    ///   - name: The name of the media to search for
    ///   - includeAdult: Whether the results should include adult media
    ///   - completion: The code to execute when the request is completed.
    func searchMedia(_ name: String, includeAdult: Bool = true, completion: @escaping ([TMDBSearchResult]?) -> Void) {
        let searchURL = "\(baseURL)/search/multi"
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
    
    
    /// Fetches the cast members for a given media ID and a given `MediaType`.
    /// - Parameters:
    ///   - id: The id of the media on TheMovieDB.org
    ///   - type: The type of media
    ///   - completion: The code to execute, when the request is completed
    func getCast(by id: Int, type: MediaType, completion: @escaping (CastWrapper?) -> Void) {
        let url = "\(baseURL)/\(type.rawValue)/\(id)/credits"
        decodeAPIURL(urlString: url, completion: completion)
    }
    
    /// Fetches the keywords for a given media ID and a given `MediaType`.
    /// - Parameters:
    ///   - id: The id of the media on TheMovieDB.org
    ///   - type: The type of media
    ///   - completion: The code to execute, when the request is completed
    func getKeywords(by id: Int, type: MediaType, completion: @escaping (KeywordsWrapper?) -> Void) {
        let url = "\(baseURL)/\(type.rawValue)/\(id)/keywords"
        decodeAPIURL(urlString: url, completion: completion)
    }
    
    /// Fetches the videos for a given media ID and a given `MediaType`.
    /// - Parameters:
    ///   - id: The id of the media on TheMovieDB.org
    ///   - type: The type of media
    ///   - completion: The code to execute, when the request is completed
    func getVideos(by id: Int, type: MediaType, completion: @escaping (VideosWrapper?) -> Void) {
        let url = "\(baseURL)/\(type.rawValue)/\(id)/videos"
        decodeAPIURL(urlString: url, completion: completion)
    }
    
    /// Fetches the translations for a given media ID and a given `MediaType`.
    /// - Parameters:
    ///   - id: The id of the media on TheMovieDB.org
    ///   - type: The type of media
    ///   - completion: The code to execute, when the request is completed
    func getTranslations(by id: Int, type: MediaType, completion: @escaping (TranslationsWrapper?) -> Void) {
        let url = "\(baseURL)/\(type.rawValue)/\(id)/translations"
        decodeAPIURL(urlString: url, completion: completion)
    }
    
    /// Decodes an API result into a given type.
    /// - Parameters:
    ///   - urlString: The URL of the API request
    ///   - completion: The code to execute when the request is complete
    func decodeAPIURL<T>(urlString: String, completion: @escaping (T?) -> Void) where T: Decodable {
        JFUtils.getRequest(urlString, parameters: [
            "api_key": apiKey,
            "language": locale
        ]) { (data) in
            guard let data = data else {
                // On fail, call the completion with nil, so the caller knows, it failed
                print("JFUtils.getRequest returned nil")
                completion(nil)
                return
            }
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(result)
            } catch let e as DecodingError {
                print("Error decoding: \(e)")
            } catch {
                print("Other error")
            }
        }
    }
    
}
