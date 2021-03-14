//
//  TMDBAPI.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class TMDBAPI {
    
    enum APIError: Error {
        case unauthorized
        case invalidResponse
        case unknown(Int)
    }
    
    static let shared = TMDBAPI()
    
    /// The base part of the TheMovieDB.org API URL
    private let baseURL = "https://api.themoviedb.org/3"
    
    private let apiKey: String = "e4304a9deeb9ed2d62eb61d7b9a2da71"
    /// The ISO 639-1 language code
    var language: String {
        JFConfig.shared.language
    }
    /// The ISO 3166-1 region code
    var region: String {
        JFConfig.shared.region
    }
    /// The combined string of language and region.
    /// Format: `languageCode-regionCode`
    var locale: String {
        return "\(language)-\(region)"
    }
    
    // TODO: Maybe just create a separate background context for each execution?
    lazy var context: NSManagedObjectContext = {
        return PersistenceController.shared.container.newBackgroundContext()
    }()
    
    var disposableContext: NSManagedObjectContext {
        PersistenceController.shared.disposableContext
    }
    
    // This is a singleton
    private init() {}
    
    // MARK: - Public functions
    
    // TODO: Save contexts
    
    /// Loads and decodes a media object from the TMDB API
    /// - Parameters:
    ///   - id: The TMDB ID of the media object
    ///   - type: The type of media
    /// - Returns: The decoded media object
    func fetchMediaAsync(id: Int, type: MediaType, completion: @escaping (Media?, Error?) -> Void) {
        self.context.perform {
            // Get the TMDB Data
            self.fetchTMDBData(for: id, type: type) { tmdbData, error in
                guard let tmdbData = tmdbData else {
                    print("Error retrieving TMDBData for \(type.rawValue) ID \(id)")
                    print(error ?? "nil")
                    self.saveContext()
                    completion(nil, error)
                    return
                }
                // Create the media
                self.context.perform {
                    var media: Media!
                    switch type {
                        case .movie:
                            media = Movie(context: self.context, tmdbData: tmdbData)
                        case .show:
                            media = Show(context: self.context, tmdbData: tmdbData)
                    }
                    self.saveContext()
                    completion(media, nil)
                }
            }
        }
    }
    
    /// Loads and decodes a media object from the TMDB API **synchronously**
    /// - Parameters:
    ///   - id: The TMDB ID of the media object
    ///   - type: The type of media
    /// - Throws: Any errors that occurred while loading or decoding the media
    /// - Returns: The media object
    func fetchMedia(id: Int, type: MediaType) throws -> Media {
        var returnMedia: Media!
        var returnError: Error?
        let group = DispatchGroup()
        group.enter()
        self.fetchMediaAsync(id: id, type: type) { (media, error) in
            defer {
                group.leave()
            }
            if let error = error {
                returnError = error
                return
            }
            if error == nil && media == nil {
                fatalError()
            }
            returnMedia = media!
        }
        group.wait()
        if let error = returnError {
            throw error
        }
        return returnMedia
    }
    
    /// Updates the given media object by re-loading the TMDB data
    /// - Parameters:
    ///   - media: The media object to update
    ///   - completion: A closure, executed after the media object has been updated
    ///   - context: The context to update the media objects in
    /// - Throws: `APIError` or `DecodingError`
    func updateMedia(_ media: Media, completion: @escaping (Error?) -> Void) {
        // Update TMDBData
        self.context.perform {
            self.fetchTMDBData(for: media.tmdbID, type: media.type) { (tmdbData, error) in
                guard let tmdbData = tmdbData else {
                    print("Error updating \(media.type.rawValue) \(media.title)")
                    print(error ?? "nil")
                    completion(error)
                    self.saveContext()
                    return
                }
                // If fetching was successful, update the media object and thumbnail
                DispatchQueue.main.async {
                    do {
                        try media.update(tmdbData: tmdbData)
                    } catch let e {
                        print("Error updating media")
                        print(e)
                        AlertHandler.showSimpleAlert(title: "Error updating", message: e.localizedDescription)
                    }
                    // Redownload the thumbnail (it may have been updated)
                    media.loadThumbnailAsync(force: true)
                    self.saveContext()
                    completion(nil)
                }
            }
        }
    }
    
    /// Loads the TMDB IDs of all media objects changed in the given timeframe
    /// - Parameters:
    ///   - startDate: The start of the timespan
    ///   - endDate: The end of the timespan
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The changed TMDB IDs
    func getChanges(from startDate: Date?, to endDate: Date, completion: @escaping ([Int]?, Error?) -> Void) {
        var dateRangeParameters: [String: Any?] = [
            "end_date": JFUtils.tmdbDateFormatter.string(from: endDate)
        ]
        if let startDate = startDate {
            dateRangeParameters["start_date"] = JFUtils.tmdbDateFormatter.string(from: startDate)
        }
        self.context.perform {
            var allResults: [MediaChangeWrapper] = []
            var requestError: Error? = nil
            // We are already in a background thread, this means we can wait for both api calls to finish
            let group = DispatchGroup()
            // Fetch changes for all media types
            for type in MediaType.allCases {
                group.enter()
                self.multiPageRequest(path: "\(type.rawValue)/changes", additionalParameters: dateRangeParameters, pageWrapper: ResultsPageWrapper.self, context: self.context) { (results: [MediaChangeWrapper]?, error: Error?) in
                    defer {
                        group.leave()
                    }
                    // If we received an error, return
                    if let error = error {
                        requestError = error
                        return
                    }
                    guard let results = results else {
                        // If results and error are nil, abort
                        return
                    }
                    allResults += results
                }
            }
            group.wait()
            self.saveContext()
            if requestError != nil {
                completion(nil, requestError)
            } else {
                // Only return the TMDB IDs that changed
                completion(allResults.map(\.id), nil)
            }
        }
    }
    
    /// Searches for media with a given query on TheMovieDB.org
    /// - Parameters:
    ///   - name: The query to search for
    ///   - includeAdult: Whether to include adult media
    ///   - completion: The completion handler executed with the search results. The search results belong to a disposable `NSManagedObjectContext` which will not be merged with the main context.
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The search results
    func searchMedia(_ query: String, includeAdult: Bool = false, completion: @escaping ([TMDBSearchResult]?, Error?) -> Void) {
        self.multiPageRequest(path: "search/multi", additionalParameters: [
            "query": query,
            "include_adult": includeAdult
        ], maxPages: JFLiterals.maxSearchPages, pageWrapper: SearchResultsPageWrapper.self, context: self.disposableContext) { (results: [TMDBSearchResult]?, error: Error?) in
            completion(results, error)
        }
    }
    
    // MARK: - Private functions
    
    /// Loads multiple pages of results and returns the accumulated data
    /// - Parameters:
    ///   - path: The API URL path to request the data from
    ///   - additionalParameters: Additional parameters for the API call
    ///   - maxPages: The maximum amount of pages to parse
    ///   - pageWrapper: The struct, the result pages get decoded into
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The accumulated results of the API calls
    private func multiPageRequest<PageWrapper: PageWrapperProtocol>(path: String, additionalParameters: [String: Any?] = [:], maxPages: Int = .max, pageWrapper: PageWrapper.Type, context: NSManagedObjectContext, completion: @escaping ([PageWrapper.ObjectWrapper]?, Error?) -> Void) {
        let decoder = self.decoder(context: context)
        context.perform {
            do {
                // Fetch the JSON in the background
                let data = try self.request(path: path, additionalParameters: additionalParameters)
                // Decode on the context thread
                let wrapper = try decoder.decode(PageWrapper.self, from: data)
                var results = wrapper.results
                
                // If we only had to load 1 page in total, we can complete now
                if wrapper.totalPages <= 1 {
                    completion(results, nil)
                    return
                }
                
                // Back to the background thread for loading the other pages
                // Load the rest of the pages
                for page in 2 ... min(wrapper.totalPages, maxPages) {
                    let newParameters = additionalParameters.merging(["page": page])
                    // Get the JSON
                    let data = try self.request(path: path, additionalParameters: newParameters)
                    // TODO: Decode on context thread asynchronously (so we can continue loading more pages)
                    let wrapper = try decoder.decode(PageWrapper.self, from: data)
                    results.append(contentsOf: wrapper.results)
                }
                completion(results, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    /// Loads and decodes a subclass of `TMDBData` for the given TMDB ID and type
    /// - Parameters:
    ///   - id: The TMDB ID to load the data for
    ///   - type: The type of media to load
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The data returned by the API call
    private func fetchTMDBData(for id: Int, type: MediaType, completion: @escaping (TMDBData?, Error?) -> Void) {
        let parameters = ["append_to_response": "keywords,translations,videos,credits"]
        decodeAPIURL(path: "\(type.rawValue)/\(id)", additionalParameters: parameters, as: TMDBData.self, context: self.context, userInfo: [.mediaType: type]) { tmdbData, error in
            completion(tmdbData, error)
        }
    }
    
    /// Loads and decodes an API URL
    /// - Parameters:
    ///   - context: The context to decode the objects with. Should be a background context, since the decoding can take some time.
    ///   - path: The API URL path to decode
    ///   - additionalParameters: Additional parameters to use for the API call
    ///   - type: The type of media
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The decoded result
    private func decodeAPIURL<T>(path: String, additionalParameters: [String: Any?] = [:], as type: T.Type, context: NSManagedObjectContext, userInfo: [CodingUserInfoKey: Any] = [:], completion: @escaping (T?, Error?) -> Void) where T: Decodable {
        // Load the JSON on a background thread
        context.perform {
            do {
                let data = try self.request(path: path, additionalParameters: additionalParameters)
                // Decode on the thread of the context (hopefully a background thread)
                let decoder = self.decoder(context: context)
                // Merge the userInfo dicts, preferring the new, user-supplied values
                decoder.userInfo.merge(userInfo)
                let result = try decoder.decode(T.self, from: data)
                completion(result, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    /// Performs an API GET request and returns the data
    /// - Parameters:
    ///   - path: The API URL path
    ///   - additionalParameters: Additional parameters to use for the API call
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The data from the API call
    private func request(path: String, additionalParameters: [String: Any?] = [:]) throws -> Data {
        let url = "\(baseURL)/\(path)"
        var parameters: [String: Any?] = [
            "api_key": apiKey,
            "language": locale,
            "region": region
        ]
        // Overwrite existing keys
        parameters.merge(additionalParameters)
        
        let group = DispatchGroup()
        group.enter()
        var data: Data? = nil
        var response: URLResponse? = nil
        var error: Error? = nil
        JFUtils.getRequest(url, parameters: parameters) { (d, r, e) in
            data = d
            response = r
            error = e
            group.leave()
        }
        
        group.wait()
        
        // If we have an error, making the api call, we throw it
        if let error = error {
            throw error
        }
        
        guard let responseData = data, let httpResponse = response as? HTTPURLResponse else {
            // The data or response is invalid, but no error was returned (otherwise we would have returned before)
            throw APIError.invalidResponse
        }
        
        // Unauthorized
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        if httpResponse.statusCode != 200 {
            print("API Request returned status code \(httpResponse.statusCode).")
            print("Headers: \(httpResponse.allHeaderFields)")
            print("Body: \(String(data: responseData, encoding: .utf8) ?? "nil")")
            throw APIError.unknown(httpResponse.statusCode)
        }
        
        // By now we have cleared all errors or non-200-responses
        return responseData
    }
    
    /// Create a new JSONDecoder with the given context as managedObjectContext
    /// - Parameter context: The context
    /// - Returns: The decoder
    private func decoder(context: NSManagedObjectContext) -> JSONDecoder {
        // Initialize the decoder and context
        let decoder = JSONDecoder()
        decoder.userInfo[.managedObjectContext] = context
        return decoder
    }
    
    func saveContext() {
        print("Saving TMDBAPI context.")
        PersistenceController.saveContext(context: self.context)
    }
    
}

/// Respresents a wrapper containing the ID of a media and whether that media is an adult media or not.
fileprivate struct MediaChangeWrapper: Codable {
    var id: Int
    var adult: Bool?
}
