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
    func request(path: String, additionalParameters: [String: Any?] = [:], completion: @escaping (Data?) -> Void) {
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
    
    // Returns a concrete subclass
    /// Fetches a subclass of `Media` from TheMovieDB.org for a given media ID and a given `MediaType`.
    /// - Parameters:
    ///   - id: The id of the media on TheMovieDB.org
    ///   - type: The type of media
    ///   - completion: The code to execute when the request is completed
    private func getTMDBData(by id: Int, type: MediaType, completion: @escaping (TMDBData?) -> Void) {
        self.request(path: "\(type.rawValue)/\(id)") { (data) in
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
    
    /// Fetches a media object for the given ID and type of media
    /// - Parameters:
    ///   - id: The id of the media to fetch
    ///   - type: The type of media
    func fetchMedia(id: Int, type: MediaType) -> Media? {
        var media: Media? = nil
        // Get the TMDB Data
        let tmdbDataGroup = DispatchGroup()
        tmdbDataGroup.enter()
        self.getTMDBData(by: id, type: type) { (tmdbData) in
            guard let tmdbData = tmdbData else {
                print("Error getting TMDB Data for \(type.rawValue) \(id)")
                tmdbDataGroup.leave()
                return
            }
            // Create the media
            if type == .movie {
                media = Movie()
            } else {
                media = Show()
            }
            media?.tmdbData = tmdbData
            media?.loadThumbnail()
            tmdbDataGroup.leave()
        }
        // FIXME: Does this create a Deadlock? Does the completion closure get executed on THIS thread?
        // Wait for TMDBData to be fetched
        tmdbDataGroup.wait()
        
        if let media = media {
            // Fetch other API stuff async
            self.startSeparateAPICalls(media: media)
        }
        
        return media
    }
    
    /// Updates a given media object by fetching the TMDB data again and overwriting existing data with the result.
    /// Does not overwrite existing data with nil or empty values.
    /// This function is executed **synchronously**.
    ///
    /// This function uses 5 API calls.
    /// 
    /// - Parameter media: The media object to update
    func updateMedia(_ media: Media) {
        // Update TMDBData
        let group = DispatchGroup()
        group.enter()
        self.getTMDBData(by: media.id, type: media.type) { (data) in
            guard let data = data else {
                print("Error updating TMDB data of \(media.type.rawValue) \(media.id)")
                group.leave()
                return
            }
            // If fetching was successful, update the media object and thumbnail
            media.tmdbData = data
            media.loadThumbnail()
            group.leave()
        }
        // FIXME: Possible Deadlock
        group.wait()
        // Update cast, keywords, videos and translations
        self.startSeparateAPICalls(media: media, sync: true)
    }
    
    /// Starts API calls to fill in the cast, keywords, videos and translations.
    /// Does not overwrite existing data with nil or empty data.
    /// - Parameter media: The media object to fill with the API call results
    /// - Parameter sync: Whether the function should be executed synchronously
    private func startSeparateAPICalls(media: Media, sync: Bool = false) {
        let group: DispatchGroup? = sync ? DispatchGroup() : nil
        group?.enter()
        self.getCast(by: media.id, type: media.type) { (wrapper) in
            if let cast = wrapper?.cast, !cast.isEmpty {
                media.cast = cast
            }
            group?.leave()
        }
        group?.enter()
        self.getKeywords(by: media.id, type: media.type) { (wrapper) in
            if let keywords = wrapper?.keywords, !keywords.isEmpty {
                media.keywords = keywords.map({ $0.name })
            }
            group?.leave()
        }
        group?.enter()
        self.getVideos(by: media.id, type: media.type) { (wrapper) in
            if let videos = wrapper?.videos, !videos.isEmpty {
                media.videos = videos
            }
            group?.leave()
        }
        group?.enter()
        self.getTranslations(by: media.id, type: media.type) { (wrapper) in
            if let translations = wrapper?.translations, !translations.isEmpty {
                media.translations = translations.map({ $0.name })
            }
            group?.leave()
        }
        // FIXME: Possible Deadlock
        group?.wait()
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
            self.request(path: "\(type.rawValue)/changes", additionalParameters: dateRangeParameters) { (data) in
                guard let data = data else {
                    print("Error loading changes")
                    completion([])
                    return
                }
                guard let wrapper = try? JSONDecoder().decode(ResultsPageWrapper<MediaChangeWrapper>.self, from: data) else {
                    print("Error decoding changes")
                    completion([])
                    return
                }
                results.append(contentsOf: wrapper.results)
                // Use a DispatchGroup to wait for all page results to fetch
                let group = DispatchGroup()
                // Load other pages, skip the first
                if wrapper.totalPages <= 1 {
                    // No need to load more pages
                    superGroup.leave()
                    return
                }
                for page in 2...wrapper.totalPages {
                    group.enter()
                    self.request(path: "\(type.rawValue)/changes", additionalParameters: ["page": page].merging(dateRangeParameters, uniquingKeysWith: { (current, _) in current })) { (data) in
                        guard let data = data else {
                            print("Error loading results page \(page)")
                            group.leave()
                            return
                        }
                        guard let wrapper = try? JSONDecoder().decode(ResultsPageWrapper<MediaChangeWrapper>.self, from: data) else {
                            print("Error decoding results page \(page)")
                            group.leave()
                            return
                        }
                        results.append(contentsOf: wrapper.results)
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    // Once all pages for this media type have been loaded and added to the results,
                    // leave the superGroup
                    superGroup.leave()
                }
            }
        }
        // Once all pages have loaded (for movie and tv), execute the completion closure
        superGroup.notify(queue: .main) {
            completion(results.map({ $0.id }))
        }
    }
    
    /// Searches for a media with a given name on TheMovieDB.org.
    /// - Parameters:
    ///   - name: The name of the media to search for
    ///   - includeAdult: Whether the results should include adult media
    ///   - completion: The code to execute when the request is completed.
    func searchMedia(_ name: String, includeAdult: Bool = true, completion: @escaping ([TMDBSearchResult]?) -> Void) {
        self.request(path: "search/multi", additionalParameters: [
            "query": name,
            "include_adult": includeAdult
        ]) { (data) in
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
        decodeAPIURL(path: "\(type.rawValue)/\(id)/credits", completion: completion)
    }
    
    /// Fetches the keywords for a given media ID and a given `MediaType`.
    /// - Parameters:
    ///   - id: The id of the media on TheMovieDB.org
    ///   - type: The type of media
    ///   - completion: The code to execute, when the request is completed
    func getKeywords(by id: Int, type: MediaType, completion: @escaping (KeywordsWrapper?) -> Void) {
        if type == .movie {
            decodeAPIURL(path: "\(type.rawValue)/\(id)/keywords", completion: { (wrapper: MovieKeywordsWrapper?) in
                completion(wrapper)
            })
        } else {
            decodeAPIURL(path: "\(type.rawValue)/\(id)/keywords", completion: { (wrapper: ShowKeywordsWrapper?) in
                completion(wrapper)
            })
        }
    }
    
    /// Fetches the videos for a given media ID and a given `MediaType`.
    /// - Parameters:
    ///   - id: The id of the media on TheMovieDB.org
    ///   - type: The type of media
    ///   - completion: The code to execute, when the request is completed
    func getVideos(by id: Int, type: MediaType, completion: @escaping (VideosWrapper?) -> Void) {
        decodeAPIURL(path: "\(type.rawValue)/\(id)/videos", completion: completion)
    }
    
    /// Fetches the translations for a given media ID and a given `MediaType`.
    /// - Parameters:
    ///   - id: The id of the media on TheMovieDB.org
    ///   - type: The type of media
    ///   - completion: The code to execute, when the request is completed
    func getTranslations(by id: Int, type: MediaType, completion: @escaping (TranslationsWrapper?) -> Void) {
        decodeAPIURL(path: "\(type.rawValue)/\(id)/translations", completion: completion)
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
