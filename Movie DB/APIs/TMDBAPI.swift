//
//  TMDBAPI.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import os.log
import UIKit

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
actor TMDBAPI {
    static let shared = TMDBAPI()
    /// The maximum number of requests that can be executed in one second. Used to calculate a cooldown period between requests
    static let maxRequestsPerSecond = 20
    /// The URLSession used by the API
    private let urlSession: URLSession = .shared
    /// The non-persistent date of our last request. Used for rate-limiting
    private var lastRequestDate: Date = .distantPast
    
    private let apiKey: String = Secrets.tmdbAPIKey
    /// The language identifier consisting of an ISO 639-1 language code and an ISO 3166-1 region code
    var locale: String { JFConfig.shared.language }
    /// The ISO 3166-1 region code, used for displaying matching release dates
    var region: String { JFConfig.shared.region }
    
    var disposableContext: NSManagedObjectContext { PersistenceController.createDisposableContext() }
    
    // This is a singleton
    private init() {}
    
    // MARK: - Public functions
    
    func cast(for id: Int, type: MediaType) async throws -> [CastMemberDummy] {
        let cast: [CastMemberDummy]
        switch type {
        case .movie:
            cast = try await decodeAPIURL(
                path: "/\(type.rawValue)/\(id)/credits",
                as: CreditsWrapper.self,
                userInfo: [.mediaType: type]
            )
            .cast
        case .show:
            cast = try await decodeAPIURL(
                path: "/\(type.rawValue)/\(id)/aggregate_credits",
                as: AggregateCreditsWrapper.self,
                userInfo: [.mediaType: type]
            )
            .cast
            .map { $0.createCastMember() }
        }
        return cast
    }
    
    /// Loads and decodes a media object from the TMDB API
    /// - Parameters:
    ///   - id: The TMDB ID of the media object
    ///   - type: The type of media
    ///   - context: The context to insert the new media object into
    /// - Returns: The decoded media object
    func media(for id: Int, type: MediaType, context: NSManagedObjectContext) async throws -> Media {
        // Get the TMDB Data (TMDBData is no NSManagedObject, so we don't need to perform in the context's thread)
        let tmdbData = try await tmdbData(for: id, type: type, context: context)
        // We need to be in the context's thread to create new medias
        let media: Media = await context.perform {
            // Create the media
            let media: Media
            switch type {
            case .movie:
                media = Movie(context: context, tmdbData: tmdbData)
            case .show:
                media = Show(context: context, tmdbData: tmdbData)
            }
            return media
        }
        media.loadThumbnail()
        return media
    }
    
    /// Updates the given media object by re-loading and replacing the TMDB data
    /// - Parameters:
    ///   - media: The media object to update
    ///   - context: The context to update the media objects in
    func updateMedia(_ media: Media, context: NSManagedObjectContext) async throws {
        // The given media object should be from the context to perform the update in
        assert(media.managedObjectContext == context || context.parent == media.managedObjectContext)
        let tmdbData = try await tmdbData(for: media.tmdbID, type: media.type, context: context)
        // Update the media in the correct thread
        await context.perform {
            // Update the media object and thumbnail
            media.update(tmdbData: tmdbData)
        }
        // We have to always reload the thumbnail, because an iCloud sync could potentially update the imagePath, leaving the loaded thumbnail in an inconsistent state
        media.loadThumbnail(force: true)
    }
    
    /// Loads the TMDB IDs of all media objects changed in the given timeframe
    /// - Parameters:
    ///   - startDate: The start of the timespan
    ///   - endDate: The end of the timespan
    /// - Returns: All TMDB IDs that changed during the given timespan
    func changedIDs(from startDate: Date?, to endDate: Date) async throws -> [MediaType: [Int]] {
        // We don't care about the time, we only provide the date in the API call
        var startDate = (startDate ?? .now).timeErased()
        let endDate = endDate.timeErased()

        // The TMDB API only allows date ranges <= 14 days. We need to use multiple requests to get larger ranges.
        // This means the API is okay with a range of e.g. 2023-01-01 to 2023-01-15
        let apiLimit = 14
        
        func numberOfDays() -> Int {
            let distance = startDate.distance(to: endDate)
            let days = distance / .day
            // Round to compensate for rounding errors, the result should always be close to full numbers,
            // since we erased the time of both dates
            assert(
                abs(days - days.rounded()) < 0.01,
                // swiftlint:disable:next line_length
                "Distance between time-erased startDate (\(startDate)) and time-erased endDate (\(endDate)) is \(days) days."
            )
            return Int(days.rounded())
        }
        
        // We need to limit the number of requests somehow
        guard numberOfDays() <= (10 * apiLimit) else {
            throw APIError.updateError
        }
        
        var results: [MediaType: [Int]] = [:]
        if numberOfDays() > apiLimit {
            // Do a recursive call to handle the part of the range that exceeds our limit
            // (e.g. for the range 1...100, the recursive call handles 1...89 and we handle 90...100,
            // if the apiLimit were 10)
            let newEndDate = endDate.addingTimeInterval(Double(-(apiLimit + 1)) * .day)
            // Fetch results from start to (end - (apiLimit + 1))
            results = try await self.changedIDs(from: startDate, to: newEndDate)
            
            // Update the startDate for the rest of the execution
            // We can subtract a full day here, since we only consider days as a lowest magnitude
            startDate = newEndDate.addingTimeInterval(.day)
            // Continue with range from (end - apiLimit) to end
        }
        
        // Construct the request parameters for the date range
        let dateRangeParameters: [String: String?] = [
            "end_date": Utils.tmdbCurrentDateFormatter.string(from: endDate),
            "start_date": Utils.tmdbCurrentDateFormatter.string(from: startDate),
        ]
        // Do both fetch requests concurrently using a task group
        let newResults = try await withThrowingTaskGroup(
            of: (MediaType, [MediaChangeWrapper]).self
        ) { group -> [MediaType: [Int]] in
            // Fetch changes for all media types
            for type in MediaType.allCases {
                // Fetch the changes for the current media type and return the child result
                _ = group.addTaskUnlessCancelled {
                    let (results, _) = try await self.multiPageRequest(
                        path: "/\(type.rawValue)/changes",
                        additionalParameters: dateRangeParameters,
                        pageWrapper: ResultsPageWrapper<MediaChangeWrapper>.self,
                        // We use a disposable context since we only use the IDs from the results
                        context: self.disposableContext
                    )
                    return (type, results)
                }
            }
            // Accumulate all child results of this group
            var allResults: [MediaType: [Int]] = [:]
            for try await (type, resultSet) in group {
                allResults[type] = resultSet.map(\.id)
            }
            // Return the accumulated results
            return allResults
        }
        // Return the union of the recursively fetched results and the results of this call
        return results.merging(newResults)
    }
    
    /// Searches for media with a given query on TheMovieDB.org
    /// - Parameters:
    ///   - query: The query to search for
    ///   - includeAdult: Whether to include adult media
    ///   - from: The first page to load results from
    ///   - to: The last page to load results from (included)
    /// - Returns: The search results and the total amount of pages available for that search term
    func searchMedia(
        _ query: String,
        includeAdult: Bool = false,
        from firstPage: Int = 1,
        to lastPage: Int = JFLiterals.maxSearchPages
    ) async throws -> (results: [TMDBSearchResult], totalPages: Int) {
        try await multiPageRequest(
            path: "/search/multi",
            additionalParameters: [
                "query": query,
                "include_adult": String(includeAdult),
            ],
            from: firstPage,
            to: lastPage,
            pageWrapper: SearchResultsPageWrapper.self,
            context: disposableContext
        )
    }
    
    /// Returns all language codes available in the TMDB API
    func tmdbLanguageCodes() async throws -> [String] {
        try await decodeAPIURL(
            path: "/configuration/primary_translations",
            as: [String].self,
            context: disposableContext
        )
    }
    
    // MARK: - Private functions
    
    /// Loads multiple pages of results by making multiple API calls and returns the accumulated data
    /// - Parameters:
    ///   - path: The API URL path to request the data from, including a `/`-prefix
    ///   - additionalParameters: Additional parameters for the API call
    ///   - from: The page to start fetching data from
    ///   - to: The last page to fetch data from before returning (included)
    ///   - pageWrapper: The type used for decoding a page
    ///   - context: The context to decode the results into
    /// - Returns: The accumulated results of the given pages and the total number of pages available for the given request
    private func multiPageRequest<PageWrapper: PageWrapperProtocol>(
        path: String,
        additionalParameters: [String: String?] = [:],
        from firstPage: Int = 1,
        to lastPage: Int = .max,
        pageWrapper: PageWrapper.Type,
        context: NSManagedObjectContext
    ) async throws -> (results: [PageWrapper.ObjectWrapper], totalPages: Int) {
        guard firstPage <= lastPage else {
            throw APIError.invalidPageRange
        }
        let decoder = decoder(context: context)
        
        // Fetch the JSON in the background
        let data = try await request(
            path: path,
            additionalParameters: additionalParameters.merging(["page": String(firstPage)])
        )
        // Decode on the correct thread
        let wrapper = try await context.perform {
            // swiftformat:disable:next redundantReturn
            return try decoder.decode(PageWrapper.self, from: data)
        }
        
        if wrapper.totalPages == 0 {
            // No results
            return ([], 0)
        } else if wrapper.totalPages < firstPage {
            // If the page we were requested to load was out of bounds
            throw APIError.pageOutOfBounds(wrapper.totalPages)
        } else if wrapper.totalPages == firstPage {
            // If we only had to load 1 page in total, we can complete now
            return (wrapper.results, wrapper.totalPages)
        }
        
        // MARK: Load the additional pages
        let additionalResults: [PageWrapper.ObjectWrapper] = try await withThrowingTaskGroup(
            of: [PageWrapper.ObjectWrapper].self
        ) { group in
            // Fetch the pages concurrently
            for page in (firstPage + 1)...min(wrapper.totalPages, lastPage) {
                // Fetch the page
                _ = group.addTaskUnlessCancelled {
                    let newParameters = additionalParameters.merging(["page": String(page)])
                    // Make the request
                    let data = try await self.request(path: path, additionalParameters: newParameters)
                    // Abort, if we are already cancelled
                    try Task.checkCancellation()
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
        
        // Return the results from page 1 + the additional results loaded from the other pages
        return (wrapper.results + additionalResults, wrapper.totalPages)
    }
    
    /// Fetches the TMDB data for the given media object
    /// - Parameters:
    ///   - id: The TMDB ID of the media object
    ///   - type: The type of media to load
    ///   - context: The context to decode the `TMDBData` into
    /// - Returns: The data returned by the API call
    func tmdbData(for id: Int, type: MediaType, context: NSManagedObjectContext) async throws -> TMDBData {
        let parameters = [
            // release_dates only for movies
            // content_ratings only for tv
            "append_to_response": "keywords,translations,videos,watch/providers" +
                (type == .movie ? ",release_dates" : ",content_ratings"),
        ]
        return try await decodeAPIURL(
            path: "/\(type.rawValue)/\(id)",
            additionalParameters: parameters,
            as: TMDBData.self,
            context: context,
            userInfo: [.mediaType: type]
        )
    }
    
    /// Loads and decodes an API URL
    /// - Parameters:
    ///   - path: The API URL path to decode, including a `/`-prefix
    ///   - additionalParameters: Additional parameters to use for the API call
    ///   - type: The type to decode the data as
    ///   - context: The context to decode the objects in
    ///   - userInfo: The `userInfo` dictionary to use for decoding
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The decoded result
    private func decodeAPIURL<T: Decodable>(
        path: String,
        additionalParameters: [String: String?] = [:],
        as type: T.Type,
        context: NSManagedObjectContext? = nil,
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) async throws -> T {
        // Load the JSON on a background thread
        let data = try await request(path: path, additionalParameters: additionalParameters)
        // Decode on the thread of the context (hopefully a background thread)
        let decoder = context == nil ? JSONDecoder() : decoder(context: context)
        // Merge the userInfo dicts, preferring the new, user-supplied values
        decoder.userInfo.merge(userInfo)
        if context != nil {
            return try await context!.perform {
                return try decoder.decode(T.self, from: data) // swiftlint:disable:this implicit_return
            }
        } else {
            return try decoder.decode(T.self, from: data)
        }
    }
    
    /// Performs an HTTP GET request and returns the data
    /// - Parameters:
    ///   - path: The API URL path, including a `/`-prefix
    ///   - additionalParameters: Additional parameters to use for the API call
    /// - Returns: The data returned by the API call
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
            URLQueryItem(name: "language", value: locale),
        ]
        
        // MARK: Collect parameters
        var parameters: [String: String?] = [
            "api_key": apiKey,
            "language": locale,
            "region": region,
        ]
        // Overwrite existing keys
        parameters.merge(additionalParameters)
        // Sort, just for better log readability
        components.queryItems = parameters
            .map(URLQueryItem.init)
            .sorted(on: \.name, by: <)
        
        // MARK: Execute Request
        // Time to wait between each request
        let cooldownTime = 1.0 / Double(Self.maxRequestsPerSecond)
        // Do a while-loop, in case another request woke up while we waited
        func calculateTimeSinceLastRequest() -> TimeInterval {
            self.lastRequestDate.distance(to: .now)
        }
        var timeSinceLastRequest = calculateTimeSinceLastRequest()
        while timeSinceLastRequest < cooldownTime {
            let waitingTime = cooldownTime - timeSinceLastRequest
            try await Task.sleep(for: .milliseconds(Int(waitingTime * 1000)))
            timeSinceLastRequest = calculateTimeSinceLastRequest()
        }
        lastRequestDate = .now
        
        // Use this instance's URLSession to limit the maximum concurrent requests
        let (data, response) = try await Utils.request(from: components.url!, session: self.urlSession)
        
        // MARK: Handle Errors
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(response)
        }
        
        // Unauthorized
        guard httpResponse.statusCode != 401 else {
            Logger.api.error("API Call unauthorized: \(httpResponse, privacy: .private)")
            throw APIError.unauthorized
        }
        
        // Status codes 2xx are ok
        guard 200...299 ~= httpResponse.statusCode else {
            Logger.api.debug("TMDB API request returned status code \(httpResponse.statusCode, privacy: .public)")
            Logger.api.debug(
                "TMDB API request body: \(String(data: data, encoding: .utf8) ?? "nil", privacy: .private)"
            )
            throw APIError.statusNotOk(httpResponse)
        }
        
        return data
    }
    
    /// Create a new JSONDecoder with the given context as the managedObjectContext
    /// - Parameter context: The context
    /// - Returns: The JSON decoder
    private func decoder(context: NSManagedObjectContext?) -> JSONDecoder {
        // Initialize the decoder and context
        let decoder = JSONDecoder()
        decoder.userInfo[.managedObjectContext] = context
        return decoder
    }
    
    /// Represents the different errors that can occurr while performing API requests
    enum APIError: Error, Equatable {
        case unauthorized
        case invalidResponse(URLResponse)
        case invalidPageRange
        case pageOutOfBounds(Int)
        case updateError
        case statusNotOk(HTTPURLResponse)
        case unknown(Int)
    }
    
    /// Respresents a wrapper containing the ID of a media and whether that media is an adult media or not.
    private struct MediaChangeWrapper: Codable {
        var id: Int
        var adult: Bool?
    }
}
