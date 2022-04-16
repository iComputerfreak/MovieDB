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
    
    enum APIError: Error, Equatable {
        case unauthorized
        case invalidResponse
        case invalidPageRange
        case pageOutOfBounds
        case unknown(Int)
    }
    
    static let shared = TMDBAPI()
    
    /// The base part of the TheMovieDB.org API URL
    private let baseURL = "https://api.themoviedb.org/3"
    
    private let apiKey: String = APIKeys.tmdbAPIKey
    /// The language identifier consisting of an ISO 639-1 language code and an ISO 3166-1 region code
    var locale: String { JFConfig.shared.language }
    /// The ISO 3166-1 region code, used for displaying matching release dates
    var region: String? { locale.components(separatedBy: "-").last }
    
    var disposableContext: NSManagedObjectContext { PersistenceController.createDisposableContext() }
    
    // This is a singleton
    private init() {}
    
    // MARK: - Public functions
    
    /// Loads and decodes a media object from the TMDB API
    /// - Parameters:
    ///   - id: The TMDB ID of the media object
    ///   - type: The type of media
    ///   - context: The context to insert the new media object in
    /// - Returns: The decoded media object
    func fetchMediaAsync(id: Int, type: MediaType, context parent: NSManagedObjectContext, completion: @escaping (Media?, Error?) -> Void) {
        // Create a background context to make the changes in, before merging them with the actual context given
        let context = parent.newBackgroundContext()
        context.perform {
            // Get the TMDB Data
            self.fetchTMDBData(for: id, type: type, context: context) { tmdbData, error in
                guard let tmdbData = tmdbData else {
                    print("Error retrieving TMDBData for \(type.rawValue) ID \(id)")
                    print(error ?? "nil")
                    completion(nil, error)
                    return
                }
                // Create the media
                context.perform {
                    var media: Media!
                    switch type {
                        case .movie:
                            media = Movie(context: context, tmdbData: tmdbData)
                        case .show:
                            media = Show(context: context, tmdbData: tmdbData)
                    }
                    // Save the changes (the new media object) to the parent context
                    PersistenceController.saveContext(context: context)
                    // Return the object from the correct context
                    completion(parent.object(with: media.objectID) as? Media, nil)
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
    func fetchMedia(id: Int, type: MediaType, context: NSManagedObjectContext) throws -> Media {
        var returnMedia: Media!
        var returnError: Error?
        let group = DispatchGroup()
        group.enter()
        self.fetchMediaAsync(id: id, type: type, context: context) { (media, error) in
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
    func updateMedia(_ media: Media, context parent: NSManagedObjectContext, completion: @escaping (Error?) -> Void) {
        // Create a background context to make the changes in, before merging them with the actual context given
        let context = parent.newBackgroundContext()
        // Update TMDBData
        context.performAndWait {
            self.fetchTMDBData(for: media.tmdbID, type: media.type, context: context) { (tmdbData, error) in
                guard let tmdbData = tmdbData else {
                    print("Error updating \(media.type.rawValue) \(media.title)")
                    print(error ?? "nil")
                    completion(error)
                    return
                }
                // Copy the media into the background context and modify it there.
                // Otherwise, the view context will be in an inconsistent state
                guard let bgMedia = context.object(with: media.objectID) as? Media else {
                    print("Update Error: Unable to copy the media object into the background context")
                    return
                }
                context.performAndWait {
                    // If fetching was successful, update the media object and thumbnail
                    bgMedia.update(tmdbData: tmdbData)
                    // Save the changes to the parent context
                    PersistenceController.saveContext(context: context)
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
    func getChangedIDs(from startDate: Date?, to endDate: Date, completion: @escaping ([Int]?, Error?) -> Void) {
        var dateRangeParameters: [String: Any?] = [
            "end_date": Utils.tmdbDateFormatter.string(from: endDate)
        ]
        if let startDate = startDate {
            dateRangeParameters["start_date"] = Utils.tmdbDateFormatter.string(from: startDate)
        }
        var allResults: [MediaChangeWrapper] = []
        var requestError: Error? = nil
        // We are already in a background thread, this means we can wait for both api calls to finish
        let group = DispatchGroup()
        // Fetch changes for all media types
        for type in MediaType.allCases {
            group.enter()
            // We specify a nil context to prevent blocking our own thread with group.wait()
            self.multiPageRequest(path: "\(type.rawValue)/changes", additionalParameters: dateRangeParameters, pageWrapper: ResultsPageWrapper.self, context: self.disposableContext) { (results: [MediaChangeWrapper]?, totalPages: Int?, error: Error?) in
                // If we received an error, return
                if let error = error {
                    requestError = error
                    group.leave()
                    return
                }
                guard let results = results else {
                    // If results and error are nil, abort
                    group.leave()
                    return
                }
                allResults += results
                group.leave()
            }
        }
        group.wait()
        if requestError != nil {
            completion(nil, requestError)
        } else {
            // Only return the TMDB IDs that changed
            completion(allResults.map(\.id), nil)
        }
    }
    
    /// Searches for media with a given query on TheMovieDB.org
    /// - Parameters:
    ///   - name: The query to search for
    ///   - includeAdult: Whether to include adult media
    ///   - completion: The completion handler called with the search results, the total number of pages that can be loaded and a possible error that occurred. The search results belong to a disposable `NSManagedObjectContext` which will not be merged with the main context.
    ///   - fromPage: The first page to load results from
    ///   - toPage: The last page to load results from
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The search results
    func searchMedia(_ query: String, includeAdult: Bool = false, fromPage: Int = 1, toPage: Int = JFLiterals.maxSearchPages, completion: @escaping ([TMDBSearchResult]?, Int?, Error?) -> Void) {
        self.multiPageRequest(path: "search/multi", additionalParameters: [
            "query": query,
            "include_adult": includeAdult
        ], fromPage: fromPage, toPage: toPage, pageWrapper: SearchResultsPageWrapper.self, context: self.disposableContext) { (results: [TMDBSearchResult]?, totalPages: Int?, error: Error?) in
            completion(results, totalPages, error)
        }
    }
    
    func getTMDBLanguageCodes(completion: @escaping ([String]?, Error?) -> Void) {
        self.decodeAPIURL(path: "configuration/primary_translations", as: [String].self, context: disposableContext, completion: completion)
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
    private func multiPageRequest<PageWrapper: PageWrapperProtocol>(path: String,
                                                                    additionalParameters: [String: Any?] = [:],
                                                                    fromPage: Int = 1,
                                                                    toPage: Int = .max,
                                                                    pageWrapper: PageWrapper.Type,
                                                                    context parent: NSManagedObjectContext,
                                                                    completion: @escaping ([PageWrapper.ObjectWrapper]?, Int?, Error?) -> Void) {
        guard fromPage <= toPage else {
            completion(nil, nil, APIError.invalidPageRange)
            return
        }
        // Create a background context to make the changes in, before merging them with the actual context given
        let context = parent.newBackgroundContext()
        let decoder = self.decoder(context: context)
        // If there was no context specified, we just use a new background context to perform the work in the background
        context.perform {
            do {
                // Fetch the JSON in the background
                let data = try self.request(path: path, additionalParameters: additionalParameters.merging(["page": fromPage]))
                // Decode on the context thread
                let wrapper = try decoder.decode(PageWrapper.self, from: data)
                var results = wrapper.results
                
                if wrapper.totalPages == 0 {
                    // No results
                    completion([], 0, nil)
                    return
                } else if wrapper.totalPages < fromPage {
                    // If the page we were requested to load was out of bounds
                    completion(nil, wrapper.totalPages, APIError.pageOutOfBounds)
                    return
                } else if wrapper.totalPages == fromPage {
                    // If we only had to load 1 page in total, we can complete now
                    completion(results, wrapper.totalPages, nil)
                    return
                }
                
                // Back to the background thread for loading the other pages
                // Load the rest of the pages
                let group = DispatchGroup()
                var returnError: Error? = nil
                for page in (fromPage + 1) ... min(wrapper.totalPages, toPage) {
                    group.enter()
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            let newParameters = additionalParameters.merging(["page": page])
                            // Get the JSON
                            let data = try self.request(path: path, additionalParameters: newParameters)
                            let wrapper = try decoder.decode(PageWrapper.self, from: data)
                            results.append(contentsOf: wrapper.results)
                            group.leave()
                        } catch {
                            returnError = error
                            group.leave()
                        }
                    }
                }
                // Wait for all pages to finish
                group.wait()
                // Save the changes to the parent context
                PersistenceController.saveContext(context: context)
                completion(results, wrapper.totalPages, returnError)
            } catch let error {
                completion(nil, nil, error)
            }
        }
    }
    
    /// Loads and decodes a subclass of `TMDBData` for the given TMDB ID and type
    /// - Parameters:
    ///   - id: The TMDB ID to load the data for
    ///   - type: The type of media to load
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The data returned by the API call
    private func fetchTMDBData(for id: Int, type: MediaType, context: NSManagedObjectContext, completion: @escaping (TMDBData?, Error?) -> Void) {
        // We don't need to create a background context since this function is private and the caller will already have created a background context
        let parameters = ["append_to_response": "keywords,translations,videos,credits,aggregate_credits"]
        decodeAPIURL(path: "\(type.rawValue)/\(id)", additionalParameters: parameters, as: TMDBData.self, context: context, userInfo: [.mediaType: type]) { tmdbData, error in
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
    private func decodeAPIURL<T>(path: String,
                                 additionalParameters: [String: Any?] = [:],
                                 as type: T.Type, context: NSManagedObjectContext,
                                 userInfo: [CodingUserInfoKey: Any] = [:],
                                 completion: @escaping (T?, Error?) -> Void) where T: Decodable {
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
            "language": locale
        ]
        // Add the region for country-specific information (i.e. theater release dates)
        if let region = region {
            parameters["region"] = region
        }
        // Overwrite existing keys
        parameters.merge(additionalParameters)
        
        let group = DispatchGroup()
        group.enter()
        var data: Data? = nil
        var response: URLResponse? = nil
        var error: Error? = nil
        Utils.getRequest(url, parameters: parameters) { (d, r, e) in
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
            print(httpResponse)
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
    private func decoder(context: NSManagedObjectContext?) -> JSONDecoder {
        // Initialize the decoder and context
        let decoder = JSONDecoder()
        decoder.userInfo[.managedObjectContext] = context
        return decoder
    }
    
}

/// Respresents a wrapper containing the ID of a media and whether that media is an adult media or not.
fileprivate struct MediaChangeWrapper: Codable {
    var id: Int
    var adult: Bool?
}
