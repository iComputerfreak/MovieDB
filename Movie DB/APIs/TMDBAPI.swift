//
//  TMDBAPI.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

class TMDBAPI {
    
    enum APIError: Error {
        case unauthorized
        case invalidResponse
        case unknown(Int)
        case noTMDBID(Int)
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
    
    // This is a singleton
    private init() {}
    
    // MARK: - Public functions
    
    /// Loads and decodes a media objects from the TMDB API
    /// - Parameters:
    ///   - id: The TMDB ID of the media object
    ///   - type: The type of media
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The decoded media object
    func fetchMedia(id: Int, type: MediaType) throws -> Media {
        // Get the TMDB Data
        let tmdbData = try self.fetchTMDBData(for: id, type: type)
        // Create the media
        var media: Media!
        switch type {
            case .movie:
                media = Movie()
            case .show:
                media = Show()
        }
        media.tmdbData = tmdbData
        media.loadThumbnail()
        return media
    }
    
    // TODO: completion is called, after the UI has been updated
    /// Updates a given media object by fetching the TMDB data again and overwriting existing data with the result.
    /// Does not overwrite existing data with nil or empty values.
    /// This function is executed **synchronously**.
    ///
    /// - Parameter media: The media object to update
    /// - Returns: Whether the update was successful
    
    /// Updates the given media object by re-loading the TMDB data
    /// - Parameters:
    ///   - media: The media object to update
    ///   - completion: A closure, executed after the media object has been updated
    /// - Throws: `APIError` or `DecodingError`
    func updateMedia(_ media: Media, completion: @escaping () -> Void = {}) throws {
        guard let id = media.tmdbData?.id else {
            // No idea what TMDB ID should be, we can't update
            throw APIError.noTMDBID(media.id)
        }
        // Update TMDBData
        let tmdbData = try self.fetchTMDBData(for: id, type: media.type)
        // If fetching was successful, update the media object and thumbnail
        DispatchQueue.main.async {
            media.tmdbData = tmdbData
            // Redownload the thumbnail (it may have been updated)
            media.loadThumbnail(force: true)
            completion()
        }
        return
    }
    
    /// Loads the TMDB IDs of all media objects changed in the given timeframe
    /// - Parameters:
    ///   - startDate: The start of the timespan
    ///   - endDate: The end of the timespan
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The changed TMDB IDs
    func getChanges(from startDate: Date?, to endDate: Date) throws -> [Int] {
        var dateRangeParameters: [String: Any?] = [
            "end_date": JFUtils.tmdbDateFormatter.string(from: endDate)
        ]
        if let startDate = startDate {
            dateRangeParameters["start_date"] = JFUtils.tmdbDateFormatter.string(from: startDate)
        }
        var results: [MediaChangeWrapper] = []
        for type in MediaType.allCases {
            // Load the changes for every type of media (movie and tv)
            results += try self.multiPageRequest(path: "\(type.rawValue)/changes", additionalParameters: dateRangeParameters, pageWrapper: ResultsPageWrapper.self)
        }
        // Only return the TMDB IDs that changed
        return results.map(\.id)
    }
    
    /// Searches for media with a given query on TheMovieDB.org
    /// - Parameters:
    ///   - name: The query to search for
    ///   - includeAdult: Whether to include adult media
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The search results
    func searchMedia(_ query: String, includeAdult: Bool = false) throws -> [TMDBSearchResult] {
        try self.multiPageRequest(path: "search/multi", additionalParameters: [
            "query": query,
            "include_adult": includeAdult
        ], maxPages: JFLiterals.maxSearchPages, pageWrapper: SearchResultsPageWrapper.self)
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
    private func multiPageRequest<PageWrapper: PageWrapperProtocol>(path: String, additionalParameters: [String: Any?] = [:], maxPages: Int = .max, pageWrapper: PageWrapper.Type) throws -> [PageWrapper.ObjectWrapper] {
        let data = try self.request(path: path, additionalParameters: additionalParameters)
        let wrapper = try JSONDecoder().decode(PageWrapper.self, from: data)
        var results = wrapper.results
        
        // If we only had to load 1 page in total, we can return now
        if wrapper.totalPages <= 1 {
            return results
        }
        
        // Load the rest of the pages
        for page in 2 ... min(wrapper.totalPages, maxPages) {
            let newParameters = additionalParameters.merging(["page": page], uniquingKeysWith: { (_, new) in new })
            let data = try self.request(path: path, additionalParameters: newParameters)
            let wrapper = try JSONDecoder().decode(PageWrapper.self, from: data)
            results.append(contentsOf: wrapper.results)
        }
        
        return results
    }
    
    /// Loads and decodes a subclass of `TMDBData` for the given TMDB ID and type
    /// - Parameters:
    ///   - id: The TMDB ID to load the data for
    ///   - type: The type of media to load
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The data returned by the API call
    private func fetchTMDBData(for id: Int, type: MediaType) throws -> TMDBData {
        let parameters = ["append_to_response": "keywords,translations,videos,credits"]
        // We can't save the type as a variable (`let type = (type == .movie) ? TMDBMovieData.self : TMDBShowData.self`), because it would result in the variable type `TMDBData.Type`
        switch type {
            case .movie:
                return try decodeAPIURL(path: "\(type.rawValue)/\(id)", additionalParameters: parameters, as: TMDBMovieData.self)
            case .show:
                return try decodeAPIURL(path: "\(type.rawValue)/\(id)", additionalParameters: parameters, as: TMDBShowData.self)
        }
    }
    
    /// Loads and decodes an API URL
    /// - Parameters:
    ///   - path: The API URL path to decode
    ///   - additionalParameters: Additional parameters to use for the API call
    ///   - type: The type of media
    /// - Throws: `APIError` or `DecodingError`
    /// - Returns: The decoded result
    private func decodeAPIURL<T>(path: String, additionalParameters: [String: Any?] = [:], as type: T.Type) throws -> T where T: Decodable {
        let data = try request(path: path, additionalParameters: additionalParameters)
        assert(T.self != TMDBData.self, "We should not return instances of the TMDBData superclass.")
        print("Decoding as \(T.self)")
        let result = try JSONDecoder().decode(T.self, from: data)
        return result
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
        parameters.merge(additionalParameters, uniquingKeysWith: { (_, new) in new })
        
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
    
}

/// Respresents a wrapper containing the ID of a media and whether that media is an adult media or not.
fileprivate struct MediaChangeWrapper: Codable {
    var id: Int
    var adult: Bool?
}
