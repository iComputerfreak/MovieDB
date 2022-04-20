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

actor TMDBAPI {
    
    enum APIError: Error, Equatable {
        case unauthorized
        case invalidResponse(URLResponse)
        case invalidPageRange
        case pageOutOfBounds(Int)
        case updateError(reason: String)
        case statusNotOk(HTTPURLResponse)
        case unknown(Int)
    }
    
    static let shared = TMDBAPI()
    
    private let apiKey: String = APIKeys.tmdbAPIKey
    /// The language identifier consisting of an ISO 639-1 language code and an ISO 3166-1 region code
    var locale: String { JFConfig.shared.language }
    /// The ISO 3166-1 region code, used for displaying matching release dates
    var region: String? { locale.components(separatedBy: "-").last }
    
    var disposableContext: NSManagedObjectContext { PersistenceController.createDisposableContext() }
    
    // TODO: Allow different instances?
    // This is a singleton
    private init() {}
    
    // MARK: - Public functions
    
    /// Loads and decodes a media object from the TMDB API
    /// - Parameters:
    ///   - id: The TMDB ID of the media object
    ///   - type: The type of media
    ///   - context: The context to insert the new media object in
    /// - Returns: The decoded media object
    func fetchMedia(for id: Int, type: MediaType, context: NSManagedObjectContext) async throws -> Media {
        // Create a child context to make the changes in, before merging them with the actual context given
        let childContext = context.newBackgroundContext()
        // Get the TMDB Data using the child context
        let tmdbData = try await self.fetchTMDBData(for: id, type: type, context: childContext)
        let childMedia: Media = await childContext.perform {
            // Create the media in the child context
            let media: Media
            switch type {
            case .movie:
                media = Movie(context: childContext, tmdbData: tmdbData)
            case .show:
                media = Show(context: childContext, tmdbData: tmdbData)
            }
            return media
        }
        // Save the changes (the new media object) into the parent context (synchronous)
        await PersistenceController.saveContext(childContext)
        // Return the object inside the parent context as the result
        // swiftlint:disable:next force_cast
        return context.object(with: childMedia.objectID) as! Media
    }
    
    /// Updates the given media object by re-loading the TMDB data
    /// - Parameters:
    ///   - media: The media object to update
    ///   - completion: A closure, executed after the media object has been updated
    ///   - context: The context to update the media objects in
    /// - Throws: `APIError` or `DecodingError`
    func updateMedia(_ media: Media, context: NSManagedObjectContext) async throws {
        // The given media object should be from the context to perform the update in
        assert(media.managedObjectContext == context)
        // Create a child context to make the changes in, before merging them with the actual context given
        let childContext = context.newBackgroundContext()
        // Fetch the TMDBData into the child context
        let tmdbData = try await self.fetchTMDBData(for: media.tmdbID, type: media.type, context: childContext)
        // Update the media in the thread of the child context
        try await childContext.perform {
            // Copy the media into the child context and modify it there.
            // Otherwise, the view context will be in an inconsistent state
            guard let bgMedia = childContext.object(with: media.objectID) as? Media else {
                throw APIError.updateError(reason: "Unable to copy the media object into the child context")
            }
            // Update the media object and thumbnail
            bgMedia.update(tmdbData: tmdbData)
        }
        // Save the changes to the parent context
        await PersistenceController.saveContext(childContext)
    }
    
    /// Loads the TMDB IDs of all media objects changed in the given timeframe
    /// - Parameters:
    ///   - startDate: The start of the timespan
    ///   - endDate: The end of the timespan
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The changed TMDB IDs
    func fetchChangedIDs(from startDate: Date?, to endDate: Date) async throws -> [Int] {
        // Construct the request parameters for the date range
        let dateRangeParameters: [String: String?] = {
            var dict: [String: String?] = ["end_date": Utils.tmdbDateFormatter.string(from: endDate)]
            if let startDate = startDate {
                dict["start_date"] = Utils.tmdbDateFormatter.string(from: startDate)
            }
            return dict
        }()
        // Do both fetch requests concurrently using a task group
        let groupResult = try await withThrowingTaskGroup(
            of: [MediaChangeWrapper].self
        ) { group -> [MediaChangeWrapper] in
            // Fetch changes for all media types
            for type in MediaType.allCases {
                // Fetch the changes for the current media type and return the child result
                group.addTask {
                    let (results, _) = try await self.multiPageRequest(
                        path: "/\(type.rawValue)/changes",
                        additionalParameters: dateRangeParameters,
                        pageWrapper: ResultsPageWrapper<MediaChangeWrapper>.self,
                        // We use a disposable context since we only use the IDs from the results
                        context: self.disposableContext)
                    return results
                }
            }
            // Accumulate all child results of this group
            var allResults: [MediaChangeWrapper] = []
            for try await resultSet in group {
                allResults.append(contentsOf: resultSet)
            }
            // Return the accumulated results
            return allResults
        }
        // Return only the IDs
        return groupResult.map(\.id)
    }
    
    // TODO: Update documentation of async functions
    /// Searches for media with a given query on TheMovieDB.org
    /// - Parameters:
    ///   - name: The query to search for
    ///   - includeAdult: Whether to include adult media
    ///   - completion: The completion handler called with the search results, the total number of pages that can be loaded and a possible error that
    ///   occurred. The search results belong to a disposable `NSManagedObjectContext` which will not be merged with the main context.
    ///   - fromPage: The first page to load results from
    ///   - toPage: The last page to load results from
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The search results
    func searchMedia(
        _ query: String,
        includeAdult: Bool = false,
        fromPage: Int = 1,
        toPage: Int = JFLiterals.maxSearchPages
    ) async throws -> (results: [TMDBSearchResult], totalPages: Int) {
        try await self.multiPageRequest(path: "/search/multi",
                                        additionalParameters: [
                                            "query": query,
                                            "include_adult": String(includeAdult)
                                        ],
                                        fromPage: fromPage,
                                        toPage: toPage,
                                        pageWrapper: SearchResultsPageWrapper.self,
                                        context: self.disposableContext)
    }
    
    func getTMDBLanguageCodes() async throws -> [String] {
        try await self.decodeAPIURL(path: "/configuration/primary_translations",
                                    as: [String].self,
                                    context: disposableContext)
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
    private func multiPageRequest<PageWrapper: PageWrapperProtocol>(
        path: String,
        additionalParameters: [String: String?] = [:],
        fromPage: Int = 1,
        toPage: Int = .max,
        pageWrapper: PageWrapper.Type,
        context: NSManagedObjectContext) async throws -> (results: [PageWrapper.ObjectWrapper], totalPages: Int) {
            
            // TODO: Use ClosedRange instead
            guard fromPage <= toPage else {
                throw APIError.invalidPageRange
            }
            // Create a child context to make the changes in, before merging them with the actual context given
            let childContext = context.newBackgroundContext()
            let decoder = self.decoder(context: childContext)

            // Fetch the JSON in the background
            // TODO: async let
            let data = try await self.request(
                path: path,
                additionalParameters: additionalParameters.merging(["page": String(fromPage)]))
            // Decode on the child context thread
            let wrapper = try await childContext.perform {
                return try decoder.decode(PageWrapper.self, from: data)
            }
            
            if wrapper.totalPages == 0 {
                // No results
                return ([], 0)
            } else if wrapper.totalPages < fromPage {
                // If the page we were requested to load was out of bounds
                throw APIError.pageOutOfBounds(wrapper.totalPages)
            } else if wrapper.totalPages == fromPage {
                // If we only had to load 1 page in total, we can complete now
                return (wrapper.results, wrapper.totalPages)
            }
            
            // MARK: Load the additional pages
            let additionalResults: [PageWrapper.ObjectWrapper] = try await withThrowingTaskGroup(
                of: [PageWrapper.ObjectWrapper].self) { group in
                // Fetch the pages concurrently
                for page in (fromPage + 1) ... min(wrapper.totalPages, toPage) {
                    // Fetch the page
                    group.addTask {
                        let newParameters = additionalParameters.merging(["page": String(page)])
                        // Make the request
                        let data = try await self.request(path: path, additionalParameters: newParameters)
                        // Decode the data in the context's thread
                        let wrapper = try await context.perform {
                            try decoder.decode(PageWrapper.self, from: data)
                        }
                        return wrapper.results
                    }
                }
                
                var allResults: [PageWrapper.ObjectWrapper] = []
                for try await results in group {
                    allResults.append(contentsOf: results)
                }
                return allResults
            }
            
            // Save the changes to the parent context
            await PersistenceController.saveContext(childContext)
            // Return the results from page 1 + the additional results loaded from the other pages
            return (wrapper.results + additionalResults, wrapper.totalPages)
    }
    
    /// Loads and decodes a subclass of `TMDBData` for the given TMDB ID and type
    /// - Parameters:
    ///   - id: The TMDB ID to load the data for
    ///   - type: The type of media to load
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The data returned by the API call
    private func fetchTMDBData(for id: Int, type: MediaType, context: NSManagedObjectContext) async throws -> TMDBData {
        // We don't need to create a background context since this function is private and the caller will already have created a background context
        let parameters = ["append_to_response": "keywords,translations,videos,credits,aggregate_credits"]
        return try await decodeAPIURL(
            path: "/\(type.rawValue)/\(id)",
            additionalParameters: parameters,
            as: TMDBData.self,
            context: context,
            userInfo: [.mediaType: type])
    }
    
    /// Loads and decodes an API URL
    /// - Parameters:
    ///   - context: The context to decode the objects with. Should be a background context, since the decoding can take some time.
    ///   - path: The API URL path to decode
    ///   - additionalParameters: Additional parameters to use for the API call
    ///   - type: The type of media
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The decoded result
    private func decodeAPIURL<T: Decodable>(path: String,
                                            additionalParameters: [String: String?] = [:],
                                            as type: T.Type, context: NSManagedObjectContext,
                                            userInfo: [CodingUserInfoKey: Any] = [:]) async throws -> T {
        // Load the JSON on a background thread
        let data = try await self.request(path: path, additionalParameters: additionalParameters)
        // Decode on the thread of the context (hopefully a background thread)
        let decoder = self.decoder(context: context)
        // Merge the userInfo dicts, preferring the new, user-supplied values
        decoder.userInfo.merge(userInfo)
        return try await context.perform {
            return try decoder.decode(T.self, from: data)
        }
    }
    
    /// Performs an API GET request and returns the data
    /// - Parameters:
    ///   - path: The API URL path, including a `/`-prefix
    ///   - additionalParameters: Additional parameters to use for the API call
    /// - Throws: Any errors that occurred during the request
    /// - Returns: The data from the API call
    private func request(path: String, additionalParameters: [String: String?] = [:]) async throws -> Data {
        // We should never have to execute GET requests on the main thread
        assert(!Thread.isMainThread)
        
        // MARK: Build URL components
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = "/3\(path)"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: locale)
        ]
        
        // MARK: Collect parameters
        var parameters: [String: String?] = [
            "api_key": apiKey,
            "language": locale
        ]
        // Add the region for country-specific information (i.e. theater release dates)
        if let region = region {
            parameters["region"] = region
        }
        // Overwrite existing keys
        parameters.merge(additionalParameters)
        components.queryItems = parameters.map(URLQueryItem.init)
        
        // MARK: Execute Request
        var request = URLRequest(url: components.url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print("Making GET Request to \(components.url!)")
        #if DEBUG
        // In Debug mode, always load the URL, never use the cache
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        #endif
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // MARK: Handle Errors
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(response)
        }
        
        // Unauthorized
        guard httpResponse.statusCode != 401 else {
            print(httpResponse)
            throw APIError.unauthorized
        }
        
        // Status codes 2xx are ok
        guard 200...299 ~= httpResponse.statusCode else {
            print("API Request returned status code \(httpResponse.statusCode).")
            print("Headers: \(httpResponse.allHeaderFields)")
            print("Body: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw APIError.statusNotOk(httpResponse)
        }
        
        return data
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
    
    /// Respresents a wrapper containing the ID of a media and whether that media is an adult media or not.
    private struct MediaChangeWrapper: Codable {
        var id: Int
        var adult: Bool?
    }
}
