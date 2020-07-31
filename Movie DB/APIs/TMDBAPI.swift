//
//  TMDBAPI.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

class TMDBAPI {
    
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
    
    /// Performs an API call using the given path and completion closure
    /// - Parameters:
    ///   - path: The api path without the starting `/`
    ///   - completion: The closure to execute, once the GET Request has been completed
    /// - Returns: Whether the operation was successful
    private func request(path: String, additionalParameters: [String: Any?] = [:], completion: @escaping (Data?) -> Void) {
        let url = "\(baseURL)/\(path)"
        var parameters: [String: Any?] = [
            "api_key": apiKey,
            "language": locale,
            "region": region
        ]
        // Overwrite existing keys
        parameters.merge(additionalParameters, uniquingKeysWith: { (_, new) in new })
        JFUtils.getRequest(url, parameters: parameters, completion: completion)
    }
    
    /// Loads multiple pages of results and appends the items
    /// - Parameters:
    ///   - path: The API path to use for the request
    ///   - additionalParameters: Additional parameters to append
    ///   - maxPages: The number of pages to load at most
    ///   - pageWrapper: A specific wrapper class to decode the result pages
    ///   - completion: The closure to execute upon completion
    private func multiPageRequest<PageWrapper: PageWrapperProtocol>(path: String, additionalParameters: [String: Any?] = [:], maxPages: Int = .max, pageWrapper: PageWrapper.Type, completion: @escaping ([PageWrapper.ObjectWrapper]) -> Void) {
            
        typealias ObjectWrapper = PageWrapper.ObjectWrapper
        
        var results: [ObjectWrapper] = []
        self.request(path: path, additionalParameters: additionalParameters) { (data) in
            guard let data = data else {
                print("Error loading first page of multi page request.")
                completion([])
                return
            }
            guard let wrapper = try? JSONDecoder().decode(PageWrapper.self, from: data) else {
                print("Error decoding first page of multi page request.")
                completion([])
                return
            }
            results.append(contentsOf: wrapper.results)
            let group = DispatchGroup()
            if wrapper.totalPages <= 1 {
                completion(results)
                return
            }
            for page in 2 ... min(wrapper.totalPages, maxPages) {
                group.enter()
                self.request(path: path, additionalParameters: additionalParameters.merging(["page": page], uniquingKeysWith: { (_, new) in new })) { (data) in
                    guard let data = data else {
                        print("Error loading results page \(page).")
                        group.leave()
                        return
                    }
                    do {
                        let wrapper = try JSONDecoder().decode(PageWrapper.self, from: data)
                        results.append(contentsOf: wrapper.results)
                        group.leave()
                    } catch let e {
                        print("Error decoding results page \(page).")
                        print(e)
                        group.leave()
                        return
                    }
                }
            }
            group.notify(queue: .main) {
                // Once all pages have been loaded and added to the results
                completion(results)
            }
        }
    }
    
    // Returns a concrete subclass
    /// Fetches a subclass of `Media` from TheMovieDB.org for a given media ID and a given `MediaType`.
    /// - Parameters:
    ///   - id: The id of the media on TheMovieDB.org
    ///   - type: The type of media
    ///   - completion: The code to execute when the request is completed
    private func fetchTMDBData(for id: Int, type: MediaType) -> TMDBData? {
        var tmdbData: TMDBData? = nil
        let group = DispatchGroup()
        group.enter()
        self.request(path: "\(type.rawValue)/\(id)", additionalParameters: ["append_to_response": "keywords,translations,videos,credits"]) { (data) in
            guard let data = data else {
                // On fail, return nil, so the caller knows, it failed
                print("JFUtils.getRequest returned nil")
                group.leave()
                return
            }
            do {
                let dataType = type == .movie ? TMDBMovieData.self : TMDBShowData.self
                tmdbData = try JSONDecoder().decode(dataType, from: data)
                group.leave()
            } catch let e as DecodingError {
                print("Error decoding: \(e)")
                group.leave()
            } catch let e {
                print("Other error: \(e)")
                group.leave()
            }
        }
        
        group.wait()
        return tmdbData
    }
    
    /// Fetches a media object for the given ID and type of media
    /// - Parameters:
    ///   - id: The id of the media to fetch
    ///   - type: The type of media
    func fetchMedia(id: Int, type: MediaType, completion: @escaping () -> Void = {}) -> Media? {
        // Get the TMDB Data
        guard let tmdbData = self.fetchTMDBData(for: id, type: type) else {
            print("Error getting TMDB Data for \(type.rawValue) \(id)")
            return nil
        }
        // Create the media
        var media: Media? = nil
        if type == .movie {
            media = Movie()
        } else {
            media = Show()
        }
        media?.tmdbData = tmdbData
        media?.loadThumbnail()
                
        return media
    }
    
    /// Updates a given media object by fetching the TMDB data again and overwriting existing data with the result.
    /// Does not overwrite existing data with nil or empty values.
    /// This function is executed **synchronously**.
    ///
    /// This function uses 5 API calls.
    /// 
    /// - Parameter media: The media object to update
    /// - Returns: Whether the update was successful
    func updateMedia(_ media: Media) -> Bool {
        guard let id = media.tmdbData?.id else {
            // No idea what TMDB ID should be
            print("Error updating media \(media.id). No TMDB Data set.")
            return false
        }
        // Update TMDBData
        guard let tmdbData = self.fetchTMDBData(for: id, type: media.type) else {
            print("Error updating TMDB data of \(media.type.rawValue) \(id)")
            return false
        }
        // If fetching was successful, update the media object and thumbnail
        DispatchQueue.main.async {
            media.tmdbData = tmdbData
            // Redownload the thumbnail (it may have been updated)
            media.loadThumbnail(force: true)
        }
        return true
    }
    
    /// Fetches the IDs of the media objects that changed in the given timeframe
    /// - Parameter completion: The closure to execute upon completion of the request
    func getChanges(from startDate: Date?, to endDate: Date, completion: @escaping ([Int]) -> Void) {
        var dateRangeParameters: [String: Any?] = [
            "end_date": JFUtils.tmdbDateFormatter.string(from: endDate)
        ]
        // If start date provided, set it
        if let startDate = startDate {
            dateRangeParameters["start_date"] = JFUtils.tmdbDateFormatter.string(from: startDate)
        }
        
        var results: [MediaChangeWrapper] = []
        let superGroup = DispatchGroup()
        for type in MediaType.allCases {
            superGroup.enter()
            self.multiPageRequest(path: "\(type.rawValue)/changes", additionalParameters: dateRangeParameters, pageWrapper: ResultsPageWrapper.self) { (wrappers: [MediaChangeWrapper]) in
                results.append(contentsOf: wrappers)
                superGroup.leave()
            }
        }
        // Once all pages have loaded (for movie and tv), execute the completion closure
        superGroup.notify(queue: .main) {
            completion(results.map(\.id))
        }
    }
    
    /// Searches for a media with a given name on TheMovieDB.org.
    /// - Parameters:
    ///   - name: The name of the media to search for
    ///   - includeAdult: Whether the results should include adult media
    ///   - completion: The code to execute when the request is completed.
    func searchMedia(_ name: String, includeAdult: Bool = true, completion: @escaping ([TMDBSearchResult]) -> Void) {
        self.multiPageRequest(path: "search/multi", additionalParameters: [
            "query": name,
            "include_adult": includeAdult
        ], maxPages: 10, pageWrapper: SearchResult.self) { (results: [TMDBSearchResult]) in
            completion(results)
        }
    }
    
    /// Decodes an API result into a given type.
    /// - Parameters:
    ///   - urlString: The URL of the API request
    ///   - completion: The code to execute when the request is complete
    func decodeAPIURL<T>(path: String, completion: @escaping (T?) -> Void) where T: Decodable {
        self.request(path: path) { (data) in
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
