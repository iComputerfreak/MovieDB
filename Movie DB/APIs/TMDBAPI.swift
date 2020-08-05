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
    }
    
    static let shared = TMDBAPI()
    
    /// The base part of the TheMovieDB.org API URL
    private let baseURL = "https://api.themoviedb.org/3"
    
    let apiKey: String = "e4304a9deeb9ed2d62eb61d7b9a2da71"
    /// The ISO-639-1 language code
    var language: String {
        JFConfig.shared.language
    }
    var region: String {
        JFConfig.shared.region
    }
    var locale: String {
        return "\(language)-\(region)"
    }
    
    private init() {}
    
    // MARK: - Public functions
    
    /// Fetches a media object for the given ID and type of media
    /// - Parameters:
    ///   - id: The id of the media to fetch
    ///   - type: The type of media
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
    func updateMedia(_ media: Media, completion: @escaping () -> Void = {}) throws -> Bool {
        guard let id = media.tmdbData?.id else {
            // No idea what TMDB ID should be
            print("Error updating media \(media.id). No TMDB Data set.")
            return false
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
        return true
    }
    
    /// Fetches the IDs of the media objects that changed in the given timeframe
    /// - Parameter completion: The closure to execute upon completion of the request
    func getChanges(from startDate: Date, to endDate: Date) throws -> [Int] {
        let dateRangeParameters: [String: Any?] = [
            "start_date": JFUtils.tmdbDateFormatter.string(from: startDate),
            "end_date": JFUtils.tmdbDateFormatter.string(from: endDate)
        ]
        var results: [MediaChangeWrapper] = []
        for type in MediaType.allCases {
            // Load the changes for every type of media (movie and tv)
            results += try self.multiPageRequest(path: "\(type.rawValue)/changes", additionalParameters: dateRangeParameters, pageWrapper: ResultsPageWrapper.self)
        }
        // Only return the TMDB IDs that changed
        return results.map(\.id)
    }
    
    /// Searches for a media with a given name on TheMovieDB.org.
    /// - Parameters:
    ///   - name: The name of the media to search for
    ///   - includeAdult: Whether the results should include adult media
    ///   - completion: The code to execute when the request is completed.
    func searchMedia(_ name: String, includeAdult: Bool = false) throws -> [TMDBSearchResult] {
        try self.multiPageRequest(path: "search/multi", additionalParameters: [
            "query": name,
            "include_adult": includeAdult
        ], maxPages: JFLiterals.maxSearchPages, pageWrapper: SearchResultsPageWrapper.self)
    }
    
    // MARK: - Private functions
    
    /// Loads multiple pages of results and appends the items
    /// - Parameters:
    ///   - path: The API path to use for the request
    ///   - additionalParameters: Additional parameters to append
    ///   - maxPages: The number of pages to load at most
    ///   - pageWrapper: A specific wrapper class to decode the result pages
    ///   - completion: The closure to execute upon completion
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
    
    // Returns a concrete subclass
    /// Fetches a subclass of `Media` from TheMovieDB.org for a given media ID and a given `MediaType`.
    /// - Parameters:
    ///   - id: The id of the media on TheMovieDB.org
    ///   - type: The type of media
    ///   - completion: The code to execute when the request is completed
    private func fetchTMDBData(for id: Int, type: MediaType) throws -> TMDBData {
        let dataType = type == .movie ? TMDBMovieData.self : TMDBShowData.self
        let tmdbData = try decodeAPIURL(path: "\(type.rawValue)/\(id)", additionalParameters: ["append_to_response": "keywords,translations,videos,credits"], as: dataType)
        return tmdbData
    }
    
    /// Decodes an API result into a given type.
    /// - Parameters:
    ///   - urlString: The URL of the API request
    ///   - completion: The code to execute when the request is complete
    /// - Throws: an `APIError` or an `DecodingError`
    private func decodeAPIURL<T>(path: String, additionalParameters: [String: Any?] = [:], as type: T.Type = T.self) throws -> T where T: Decodable {
        let data = try request(path: path)
        let result = try JSONDecoder().decode(T.self, from: data)
        return result
    }
    
    /// Performs an API call using the given path and completion closure
    /// - Parameters:
    ///   - path: The api path without the starting `/`
    ///   - completion: The closure to execute, once the GET Request has been completed
    /// - Returns: Whether the operation was successful
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
