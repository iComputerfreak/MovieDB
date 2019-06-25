//
//  JustWatchAPI.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

struct JustWatchAPI {
    
    let baseURL = "https://apis.justwatch.com/content/"
    let header = ""
    
    var locale: String
    
    func getQuery() {
        
    }
    
    // Search a movie by name
    func searchMovie(query: String?, ageCertifications: [String]? = nil, contentTypes: [String]? = nil, providers: [String]? = nil, genres: [String]? = nil, languages: [String]? = nil, releaseYearFrom: Int? = nil, releaseYearUntil: Int? = nil, monetizationTypes: [String]? = nil, page: Int? = nil, pageSize: Int? = nil) {
        let url = URL(string: baseURL + "titles/\(locale)/popular")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any?] = [
            "age_certifications": ageCertifications,
            "content_types": contentTypes,
            "presentation_types": nil,
            "providers": providers,
            "genres": genres,
            "languages": languages,
            "release_year_from": releaseYearFrom,
            "release_year_until": releaseYearUntil,
            "monetization_types": monetizationTypes,
            "min_price": nil,
            "max_price": nil,
            "nationwide_cinema_releases_only": nil,
            "scoring_filter_types": nil,
            "cinema_release": nil,
            "query": query,
            "page": page,
            "page_size": pageSize,
            "timeline_type": nil
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                print("headerFields = \(String(describing: response.allHeaderFields))")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            try! responseString!.write(to: URL(fileURLWithPath: "/Users/jonasfrey/Desktop/result.json"), atomically: true, encoding: .utf8)
        }
        task.resume()
        
    }
    
    // Get movie information by id
    func getMovie() {
        
    }
    
}
